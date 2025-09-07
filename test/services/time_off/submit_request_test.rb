require "test_helper"

class TimeOffSubmitRequestTest < ActiveSupport::TestCase
  setup do
    @employee = User.create!(email: "emp3@test.com", password: "password", role: :employee)
    @vac = TimeOffType.create!(name: "Vacation")
  end

  test "creates pending request when valid" do
    req = TimeOff::SubmitRequest.new.call(user: @employee, params: {time_off_type_id: @vac.id, start_date: Date.current + 2, end_date: Date.current + 3, reason: "ok"})
    assert req.persisted?
    assert req.pending?
  end

  test "rejects past dates" do
    req = TimeOff::SubmitRequest.new.call(user: @employee, params: {time_off_type_id: @vac.id, start_date: Date.current - 2, end_date: Date.current - 1})
    refute req.persisted?
    assert_includes req.errors.full_messages.join, "cannot be in the past"
  end

  test "rejects exceeding limit" do
    TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 1, end_date: Date.current + 19, status: :approved)
    req = TimeOff::SubmitRequest.new.call(user: @employee, params: {time_off_type_id: @vac.id, start_date: Date.current + 30, end_date: Date.current + 31})
    refute req.persisted?
    assert_includes req.errors.full_messages.join, "Vacation limit exceeded"
  end
end

