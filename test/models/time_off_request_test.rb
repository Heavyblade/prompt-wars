require "test_helper"

class TimeOffRequestTest < ActiveSupport::TestCase
  test "invalid when end before start" do
    r = TimeOffRequest.new(start_date: Date.current + 2, end_date: Date.current + 1)
    r.validate
    assert_includes r.errors[:end_date], "must be on or after start date"
  end

  test "invalid when start in past" do
    r = TimeOffRequest.new(start_date: Date.current - 1, end_date: Date.current)
    r.validate
    assert_includes r.errors[:start_date], "cannot be in the past"
  end
end

