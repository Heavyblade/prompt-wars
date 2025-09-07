# Ruby Engineer Mini Project: Employee Time-Off Tracking System  

## Overview  
Build a **Rails 8+ API-first application** for tracking employee time-off requests, with a **server-rendered frontend**. The solution should follow **Ruby on Rails conventions**, RESTful design, and include well-structured tests.  

---

## Project Requirements  

### Core Features  

1. **Employee Management**  
   - Employees are created by an **admin interface** (no self-registration).  
   - Employees can log in to the system.  
   - Basic profile (name, email, department, manager).  
   - Role-based access with **static roles**: Employee, Manager, Admin.  

2. **Time-Off Requests**  
   - Employees can submit requests for vacation, sick leave, or personal time.  
   - Requests include: type, date range, and reason.  
   - Track request status (pending, approved, denied).  
   - Employees can view their request history.  

3. **Approval Workflow**  
   - Managers approve/deny requests for their direct reports.  
   - Admins can manage all requests across the organization.  
   - **No multi-level approvals** required.  
   - Email notifications are simulated (logged or background job).  

4. **API & Frontend**  
   - Expose a **JSON:API-compliant RESTful API** for third-party consumption.  
   - Provide a **reasonably styled MVP frontend** using Rails views (ERB/Haml) + Bootstrap.  
   - Follow Rails best practices with layouts, partials, and helpers.  

---

## Technical Requirements  

### Backend (Rails 8+)  
- **Authentication**: Devise (preferred) or Rails session-based login.  
- **Authorization**: Role-based (Pundit or custom).  
- **Database**: SQLite with migrations and seeds.  
- **API Design**: RESTful JSON endpoints, following Rails routing conventions.  
- **Testing**: RSpec with model, request, and workflow coverage.  
- **Background Jobs**: Sidekiq or ActiveJob for notifications.  
- **Data Integrity**: Rails validations and custom business rules.  
- **Code Quality**: Slim controllers, reusable service objects for business logic.  

### Suggested Database Schema  
```ruby
# Suggested models (flexible — modify as needed):
- User (employee info, role, manager_id, department_id)
- Department (name, manager_id)
- TimeOffType (vacation, sick, personal)
- TimeOffRequest (user_id, time_off_type_id, start_date, end_date, reason, status)
- Approval (time_off_request_id, approver_id, status, timestamps)
```

### Business Rules  
- Employees cannot request time off in the past.  
- Overlapping requests must be prevented or flagged.  
- Vacation limits reset on a **rolling 12-month basis**.  
- Vacation limits are **enterprise-wide**, not per department.  
- Approval must come from the employee’s manager (or admin).  
- Employees cannot approve their own requests.  

---

## Deliverables  

1. **Rails Application**  
   - Functional app with migrations, seeds, and sample data.  
   - Clear commit history showing incremental progress.  
   - Optional: AI-assisted generation documented in commits.  

2. **API Documentation**  
   - OpenAPI/Swagger spec **or** Markdown docs with request/response examples.  

3. **Test Suite**  
   - Model tests for validations and business rules.  
   - Request specs for API endpoints.  
   - Feature/system tests for key frontend flows.  

4. **README**  
   - Setup instructions (dependencies, DB setup, running tests).  
   - Where AI-assisted coding was useful.  
   - Trade-offs and future improvements.  

---

## Code Style & Conventions  

- **Ruby Style**: Enforce RuboCop with Rails ruleset.  
- **Linting/Formatting**: RuboCop or StandardRB in CI/pre-commit hooks.  
- **Directory Structure**: Follow Rails conventions (`app/models`, `app/controllers`, `app/views`, `app/services`).  
- **Naming**: Rails pluralization and RESTful naming (e.g., `time_off_requests_controller.rb`).  
- **Git Practices**: Commit small, descriptive changes with meaningful messages.  
- **Tests**: Prefer RSpec with `let`, `context`, and `shared_examples`.  
- **Documentation**: Inline YARD for service objects/POROs.  
- **Background Jobs**: Place Sidekiq jobs under `app/jobs`.  
- **Mailers**: Use `ActionMailer` with previews in `test/mailers/previews`.  
