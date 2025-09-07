class TimeOffRequestsController < ApplicationController
  before_action :require_login
  before_action :set_request, only: [:show, :destroy, :approve, :deny]

  def index
    @time_off_requests = current_user.time_off_requests.order(created_at: :desc)
  end

  def new
    @time_off_request = TimeOffRequest.new
  end

  def create
    @time_off_request = TimeOff::SubmitRequest.new.call(user: current_user, params: request_params)
    if @time_off_request.persisted?
      notify_manager(@time_off_request)
      redirect_to @time_off_request, notice: "Request submitted"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize_owner!
  end

  def destroy
    authorize_owner!
    if @time_off_request.pending?
      @time_off_request.destroy
      redirect_to time_off_requests_path, notice: "Request canceled"
    else
      redirect_to @time_off_request, alert: "Only pending requests can be canceled"
    end
  end

  def approve
    authorize_manager_or_admin_for!(@time_off_request)
    TimeOff::Decision.new.approve!(request: @time_off_request, approver: current_user)
    NotifyEmployeeDecisionJob.perform_later(@time_off_request.user_id, @time_off_request.id, "approved")
    redirect_to redirect_after_decision, notice: "Request approved"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to redirect_after_decision, alert: e.record.errors.full_messages.to_sentence
  end

  def deny
    authorize_manager_or_admin_for!(@time_off_request)
    TimeOff::Decision.new.deny!(request: @time_off_request, approver: current_user)
    NotifyEmployeeDecisionJob.perform_later(@time_off_request.user_id, @time_off_request.id, "denied")
    redirect_to redirect_after_decision, notice: "Request denied"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to redirect_after_decision, alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_request
    @time_off_request = TimeOffRequest.find(params[:id])
  end

  def request_params
    params.require(:time_off_request).permit(:time_off_type_id, :start_date, :end_date, :reason)
  end

  def authorize_owner!
    unless @time_off_request.user_id == current_user.id || current_user.admin?
      redirect_to time_off_requests_path, alert: "Not authorized"
    end
  end

  def authorize_manager_or_admin_for!(request)
    unless manager_of?(request.user) && !current_user.id.equal?(request.user_id) || current_user.admin?
      redirect_to time_off_requests_path, alert: "Not authorized"
    end
  end

  def redirect_after_decision
    if current_user.admin?
      admin_time_off_requests_path
    elsif current_user.manager?
      manager_time_off_requests_path
    else
      time_off_requests_path
    end
  end

  def notify_manager(request)
    manager_id = request.user.manager_id
    return unless manager_id
    NotifyManagerJob.perform_later(manager_id, request.id)
  end
end

