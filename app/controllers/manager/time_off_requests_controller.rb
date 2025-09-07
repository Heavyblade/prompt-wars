module Manager
  class TimeOffRequestsController < ApplicationController
    before_action :require_login
    before_action :require_manager_or_admin!

    def index
      if current_user.admin?
        @time_off_requests = TimeOffRequest.order(created_at: :desc)
      else
        team_user_ids = current_user.direct_reports.select(:id)
        @time_off_requests = TimeOffRequest.where(user_id: team_user_ids).order(created_at: :desc)
      end
    end
  end
end

