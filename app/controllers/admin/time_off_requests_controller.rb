module Admin
  class TimeOffRequestsController < ApplicationController
    before_action :require_login
    before_action :require_admin!

    def index
      @time_off_requests = TimeOffRequest.order(created_at: :desc)
    end
  end
end

