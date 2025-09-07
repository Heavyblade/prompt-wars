module Api
  module V1
    class TimeOffRequestsController < BaseController
      before_action :set_request, only: [:show, :approve, :deny]

      def index
        @requests = if current_user.admin?
          TimeOffRequest.all
        elsif current_user.manager?
          ids = current_user.direct_reports.select(:id)
          TimeOffRequest.where(user_id: ids)
        else
          current_user.time_off_requests
        end.order(created_at: :desc)
        render json: @requests.as_json(include: {time_off_type: {only: [:name]}}, methods: [:status])
      end

      def show
        unless @time_off_request.user_id == current_user.id || manager_of?(@time_off_request.user)
          return head :forbidden
        end
        render json: @time_off_request.as_json(include: {time_off_type: {only: [:name]}}, methods: [:status])
      end

      def create
        request = TimeOff::SubmitRequest.new.call(user: current_user, params: request_params)
        if request.persisted?
          manager_id = current_user.manager_id
          NotifyManagerJob.perform_later(manager_id, request.id) if manager_id
          render json: request.as_json, status: :created
        else
          render json: {errors: request.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def approve
        return head :forbidden unless manager_of?(@time_off_request.user) && current_user.id != @time_off_request.user_id
        TimeOff::Decision.new.approve!(request: @time_off_request, approver: current_user)
        NotifyEmployeeDecisionJob.perform_later(@time_off_request.user_id, @time_off_request.id, "approved")
        render json: @time_off_request.as_json
      end

      def deny
        return head :forbidden unless manager_of?(@time_off_request.user) && current_user.id != @time_off_request.user_id
        TimeOff::Decision.new.deny!(request: @time_off_request, approver: current_user)
        NotifyEmployeeDecisionJob.perform_later(@time_off_request.user_id, @time_off_request.id, "denied")
        render json: @time_off_request.as_json
      end

      private

      def set_request
        @time_off_request = TimeOffRequest.find(params[:id])
      end

      def request_params
        params.require(:time_off_request).permit(:time_off_type_id, :start_date, :end_date, :reason)
      end
    end
  end
end

