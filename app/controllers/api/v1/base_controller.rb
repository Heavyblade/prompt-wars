module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_token!

      attr_reader :current_user

      private

      def authenticate_token!
        token = request.headers['X-Auth-Token']
        @current_user = User.find_by(remember_token: token)
        head :unauthorized unless @current_user
      end

      def manager_of?(user)
        return true if current_user&.admin?
        current_user&.manager? && user.manager_id == current_user.id
      end
    end
  end
end

