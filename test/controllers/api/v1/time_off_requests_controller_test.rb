require "test_helper"

class Api::V1::TimeOffRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "api_admin@test.com", password: "password", role: :admin)
    @manager = User.create!(email: "api_mgr@test.com", password: "password", role: :manager)
    @employee = User.create!(email: "api_emp@test.com", password: "password", role: :employee, manager: @manager)
    @vac = TimeOffType.create!(name: "Vacation")
    @mgr_token = @manager.remember_token
    @emp_token = @employee.remember_token
    @adm_token = @admin.remember_token
  end

  test "employee sees only own requests" do
    TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 1, end_date: Date.current + 1)
    other_emp = User.create!(email: "api_emp2@test.com", password: "password", role: :employee)
    TimeOffRequest.create!(user: other_emp, time_off_type: @vac, start_date: Date.current + 2, end_date: Date.current + 2)

    get "/api/v1/time_off_requests", headers: {"X-Auth-Token" => @emp_token}
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.length
  end

  test "manager sees team requests" do
    TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 1, end_date: Date.current + 1)
    get "/api/v1/time_off_requests", headers: {"X-Auth-Token" => @mgr_token}
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.length
  end

  test "admin sees all requests" do
    2.times { |i| TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + i + 1, end_date: Date.current + i + 1) }
    get "/api/v1/time_off_requests", headers: {"X-Auth-Token" => @adm_token}
    assert_response :success
    body = JSON.parse(response.body)
    assert_operator body.length, :>=, 2
  end

  test "manager can approve a team request" do
    req = TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 5, end_date: Date.current + 6)
    post "/api/v1/time_off_requests/#{req.id}/approve", headers: {"X-Auth-Token" => @mgr_token}
    assert_response :success
    assert_equal "approved", req.reload.status
  end

  test "employee cannot approve own request" do
    req = TimeOffRequest.create!(user: @employee, time_off_type: @vac, start_date: Date.current + 5, end_date: Date.current + 6)
    post "/api/v1/time_off_requests/#{req.id}/approve", headers: {"X-Auth-Token" => @emp_token}
    assert_response :forbidden
  end
end

