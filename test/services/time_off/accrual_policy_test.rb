require "test_helper"

class TimeOffAccrualPolicyTest < ActiveSupport::TestCase
  setup do
    @employee = User.create!(email: "emp2@test.com", password: "password", role: :employee)
    @vac = TimeOffType.create!(name: "Vacation")
  end

  test "within limit allows request" do
    # 5 days already approved, limit 20
    TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 1, end_date: Date.current + 5, status: :approved)
    policy = TimeOff::AccrualPolicy.new
    new_req = TimeOffRequest.new(user: @employee, time_off_type: @vac, start_date: Date.current + 10, end_date: Date.current + 12)
    assert policy.within_vacation_limit?(user: @employee, new_request: new_req)
  end

  test "exceeding limit blocks request" do
    # 19 days already approved
    TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 1, end_date: Date.current + 19, status: :approved)
    policy = TimeOff::AccrualPolicy.new
    new_req = TimeOffRequest.new(user: @employee, time_off_type: @vac, start_date: Date.current + 30, end_date: Date.current + 31)
    refute policy.within_vacation_limit?(user: @employee, new_request: new_req)
  end
end

