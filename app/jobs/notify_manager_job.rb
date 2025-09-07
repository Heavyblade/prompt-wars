class NotifyManagerJob < ApplicationJob
  queue_as :default

  def perform(manager_id, request_id)
    manager = User.find_by(id: manager_id)
    request = TimeOffRequest.find_by(id: request_id)
    return unless manager && request
    TimeOffMailer.request_submitted(manager, request).deliver_later
  end
end

