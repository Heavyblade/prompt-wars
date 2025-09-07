require "application_system_test_case"

class TimeOffFlowTest < ApplicationSystemTestCase
  test "employee submits and manager approves a request" do
    manager = User.create!(email: "sys_mgr@test.com", password: "password", role: :manager)
    employee = User.create!(email: "sys_emp@test.com", password: "password", role: :employee, manager: manager)
    TimeOffType.create!(name: "Vacation")

    # Sign in as employee
    visit sign_in_path
    fill_in "Email", with: employee.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    # Create request
    visit new_time_off_request_path
    select "Vacation", from: "Type"
    fill_in "Start date", with: (Date.current + 2).to_s
    fill_in "End date", with: (Date.current + 3).to_s
    fill_in "Reason", with: "Vacation"
    click_button "Submit"

    assert_text "Request submitted"

    # Sign out employee and sign in as manager
    click_button "Sign out"
    visit sign_in_path
    fill_in "Email", with: manager.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit manager_time_off_requests_path
    assert_text employee.email.split("@").first
  end
end
