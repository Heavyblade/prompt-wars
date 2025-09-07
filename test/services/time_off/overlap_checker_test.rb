require "test_helper"

class TimeOffOverlapCheckerTest < ActiveSupport::TestCase
  setup do
    @employee = User.create!(email: "emp@test.com", password: "password", role: :employee)
    @type = TimeOffType.create!(name: "Vacation")
  end

  test "detects overlapping pending/approved requests" do
    TimeOffRequest.create!(user: @employee, time_off_type: @type, start_date: Date.current + 2, end_date: Date.current + 4, status: :approved)

    checker = TimeOff::OverlapChecker.new
    assert checker.overlap_exists?(user: @employee, start_date: Date.current + 3, end_date: Date.current + 5)
  end

  test "no overlap when non-overlapping" do
    TimeOffRequest.create!(user: @employee, time_off_type: @type, start_date: Date.current + 10, end_date: Date.current + 12, status: :approved)

    checker = TimeOff::OverlapChecker.new
    refute checker.overlap_exists?(user: @employee, start_date: Date.current + 2, end_date: Date.current + 3)
  end
end

