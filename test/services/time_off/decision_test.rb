require "test_helper"

class TimeOffDecisionTest < ActiveSupport::TestCase
  setup do
    @manager = User.create!(email: "mgr@test.com", password: "password", role: :manager)
    @employee = User.create!(email: "emp4@test.com", password: "password", role: :employee, manager: @manager)
    @vac = TimeOffType.create!(name: "Vacation")
    @request = TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 2, end_date: Date.current + 3, status: :pending)
  end

  test "approve updates status and approval" do
    TimeOff::Decision.new.approve!(request: @request, approver: @manager)
    assert @request.reload.approved?
    assert_equal @manager.id, @request.approval.approver_id
    assert @request.approval.approved?
  end

  test "deny updates status and approval" do
    TimeOff::Decision.new.deny!(request: @request, approver: @manager)
    assert @request.reload.denied?
    assert_equal @manager.id, @request.approval.approver_id
    assert @request.approval.denied?
  end
end

