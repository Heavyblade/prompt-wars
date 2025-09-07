class TimeOffMailer < ApplicationMailer
  def request_submitted(manager, request)
    @manager = manager
    @request = request
    mail(to: manager.email, subject: "New time-off request submitted")
  end

  def request_decided(user, request, decision)
    @user = user
    @request = request
    @decision = decision
    mail(to: user.email, subject: "Your time-off request was #{decision}")
  end
end

