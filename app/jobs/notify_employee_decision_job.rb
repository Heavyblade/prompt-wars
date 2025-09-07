class NotifyEmployeeDecisionJob < ApplicationJob
  queue_as :default

  def perform(user_id, request_id, decision)
    user = User.find_by(id: user_id)
    request = TimeOffRequest.find_by(id: request_id)
    return unless user && request
    TimeOffMailer.request_decided(user, request, decision).deliver_later
  end
end

