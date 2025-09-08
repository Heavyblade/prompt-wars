class TimeOffMailerPreview < ActionMailer::Preview
  def request_submitted
    manager = sample_manager
    request = sample_request
    TimeOffMailer.request_submitted(manager, request)
  end

  def request_decided
    user = sample_employee
    request = sample_request
    TimeOffMailer.request_decided(user, request, "approved")
  end

  private

  def sample_employee
    User.new(first_name: "Alex", last_name: "Employee", email: "alex@example.com")
  end

  def sample_manager
    User.new(first_name: "Mona", last_name: "Manager", email: "mona@example.com")
  end

  def sample_request
    TimeOffRequest.new(
      user: sample_employee,
      time_off_type: TimeOffType.new(name: "Vacation"),
      start_date: Date.current + 7,
      end_date: Date.current + 10,
      reason: "Visiting family"
    )
  end
end

