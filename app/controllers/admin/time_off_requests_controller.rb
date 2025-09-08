module Admin
  class TimeOffRequestsController < ApplicationController
    before_action :require_login
    before_action :require_admin!

    def index
      scope = TimeOffRequest.order(created_at: :desc)
      scope = scope.where(status: :pending) unless params[:all] == '1'
      @time_off_requests = scope
    end
  end
end
