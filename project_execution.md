# Project Execution Plan: Employee Time-Off Tracking System

This plan is tailored to the current Rails 8 app in this repo, which already includes Tailwind, Haml, Clearance (authentication), Solid Queue/Cache/Cable, and Minitest. Where the original plan suggests different tools (e.g., Devise, Pundit, Bootstrap, Sidekiq, RSpec), this plan minimizes churn and aligns with what exists, while noting optional upgrades.

The plan is organized into concrete phases with actionable steps that Cursor, Windsurf, Codex CLI, or Gemini can execute. Each step lists commands, files to add/change, and acceptance criteria.

Notes:
- Use Tailwind/Flowbite already present for styling (instead of Bootstrap).
- Keep Clearance for authentication.
- Use Solid Queue via ActiveJob for background work and ActionMailer for notifications.
- Authorization can be done with Pundit or simple role checks; below we add Pundit for clarity but call out a pure-Rails alternative.
- The repo currently uses Minitest. The requirements prefer RSpec. The plan includes an option to add RSpec while keeping Minitest temporarily or migrating entirely.

---

## Phase 0 — Project Hygiene

- Linting/quality:
  - Ensure RuboCop (already in Gemfile) is configured: `.rubocop.yml` with Rails omakase config.
  - Ensure `brakeman` works in CI.

Commands:
- None required immediately; add configs alongside later phases.

Acceptance:
- `bundle exec rubocop` runs locally.
- `bundle exec brakeman` runs locally.

---

## Phase 1 — Domain Modeling & Migrations

Goal: Introduce core tables and relationships.

Models:
- `User` (already exists via Clearance) — add attributes and associations:
  - Columns: `first_name`, `last_name`, `role` (enum: employee, manager, admin), `department_id` (nullable), `manager_id` (nullable, FK to users)
- `Department` (name, manager_id)
- `TimeOffType` (name: [vacation, sick, personal], active:boolean)
- `TimeOffRequest` (user_id, time_off_type_id, start_date, end_date, reason:text, status: enum [pending, approved, denied])
- `Approval` (time_off_request_id, approver_id, status, decided_at)

Steps:
1) Generate migrations and models (skip model for User; only a migration):
   - `bin/rails g migration AddProfileAndRoleToUsers first_name:string last_name:string role:integer:default\=0 department:references manager:references{to\:users}`
   - `bin/rails g model Department name:string manager:references{to\:users}`
   - `bin/rails g model TimeOffType name:string:index active:boolean:default\=true`
   - `bin/rails g model TimeOffRequest user:references time_off_type:references start_date:date end_date:date reason:text status:integer:default\=0`
   - `bin/rails g model Approval time_off_request:references approver:references{to\:users} status:integer:default\=0 decided_at:datetime`

2) Update models with associations/enums/validations:
   - `app/models/user.rb`: add `enum :role, { employee: 0, manager: 1, admin: 2 }`; `belongs_to :department, optional: true`; `belongs_to :manager, class_name: "User", optional: true`; `has_many :direct_reports, class_name: "User", foreign_key: :manager_id`; `has_many :time_off_requests`.
   - `app/models/department.rb`: `has_many :users`; `belongs_to :manager, class_name: "User", optional: true`.
   - `app/models/time_off_type.rb`: validations on `name`, presence/uniqueness; seed defaults.
   - `app/models/time_off_request.rb`: `belongs_to :user`; `belongs_to :time_off_type`; `has_one :approval`. `enum :status, { pending: 0, approved: 1, denied: 2 }`.
   - `app/models/approval.rb`: `belongs_to :time_off_request`; `belongs_to :approver, class_name: "User"`; `enum :status, { pending: 0, approved: 1, denied: 2 }`.

3) Business rule validations (initial pass):
   - In `TimeOffRequest`: validate `start_date <= end_date`; `start_date >= Date.current` (no past start dates).
   - Add a custom validation to prevent overlapping approved/pending requests for the same user and date range (service extraction later).

4) Run migrations:
   - `bin/rails db:migrate`

Acceptance:
- Schema includes all tables/columns; enums present on models; basic validations compile.

---

## Phase 2 — Seeds and TimeOff Types

Goal: Provide sample data to demo flows.

Steps:
1) Update `db/seeds.rb` to:
   - Create `TimeOffType` seeds: vacation, sick, personal.
   - Create one department and three users: admin, manager, employee (with relationships set and simple passwords via Clearance).

2) Load seeds:
   - `bin/rails db:seed`

Acceptance:
- `TimeOffType.count >= 3`; users present with roles; one department exists.

---

## Phase 3 — Authorization (Pundit or Custom)

Goal: Enforce role-based access.

Option A: Add Pundit (recommended):
- Gemfile: `gem 'pundit'`
- `bundle install`
- `bin/rails g pundit:install`
- Policies:
  - `TimeOffRequestPolicy`: 
    - `index?`: employee can see own; manager can see team; admin can see all.
    - `create?`: employee true; manager/admin true.
    - `update?/destroy?`: allowed if request pending and owned by employee or managed by manager/admin.
    - `approve?/deny?`: manager for direct reports; admin for all.
  - `ApprovalPolicy`: similar to approve/deny logic.

Option B: Simple custom checks:
- Add helpers in `ApplicationController` like `require_admin!`, `require_manager!`, `require_owner_or_admin!` and call them in controllers.

Acceptance:
- Unauthorized access returns 403/redirects for HTML; 403 JSON for API.

---

## Phase 4 — Controllers, Routes, Views (HTML)

Goal: Provide a minimal server-rendered UI using Haml + Tailwind.

Routes (`config/routes.rb`):
- Add Clearance routes (already present via engine) and resources:
  - `resources :time_off_requests` (index, new, create, show, destroy)
  - `resources :approvals, only: [:update]` with member actions `approve`/`deny`
  - `namespace :admin do resources :users; resources :departments; resources :time_off_requests, only: :index end`
  - `namespace :manager do resources :time_off_requests, only: :index end`

Controllers:
- `TimeOffRequestsController`:
  - `before_action :require_login`
  - Actions: index (own requests), new/create, show, destroy (if pending & owner).
  - On create: invoke service `TimeOff::SubmitRequest` (see Phase 6) and render flash errors.
- `Manager::TimeOffRequestsController`: index shows direct reports’ requests.
- `Admin::TimeOffRequestsController`: index shows all requests.
- `ApprovalsController`:
  - member actions `approve`/`deny` for managers/admins; enqueue notification job.

Views (Haml):
- `app/views/time_off_requests/index.html.haml`, `new.html.haml`, `show.html.haml` with Tailwind classes.
- Partial `_form.html.haml` with fields: type, start_date, end_date, reason.
- Navigation (layout) shows role and links to Manager/Admin dashboards if applicable.

Acceptance:
- Employee can submit and see their requests.
- Manager/Admin can browse appropriate lists.

---

## Phase 5 — JSON API (v1)

Goal: Expose RESTful JSON endpoints; approximate JSON:API structure using Jbuilder or `jsonapi-serializer`.

Option A (no extra gem): Jbuilder
- Namespaced controllers under `Api::V1` for `time_off_requests`, `approvals`, `time_off_types`, `departments`.
- Add token auth via header `X-Auth-Token` matched to `User.remember_token` or session-based for same-origin.
- `ApplicationController` API branch: skip CSRF, set `current_user` via token.
- Jbuilder views: render `data`, `type`, `id`, and `attributes` keys to follow JSON:API shape.

Option B (extra gem): `jsonapi-serializer`
- Gemfile: `gem 'jsonapi-serializer'`; create serializers for each model.

Routes:
- `namespace :api do namespace :v1 do resources :time_off_requests do member do post :approve; post :deny; end end; resources :time_off_types, only: [:index]; resources :departments, only: [:index, :show]; end end`

Acceptance:
- CRUD for `time_off_requests` works with JSON.
- Approve/Deny endpoints enforce role rules and return updated resource.

---

## Phase 6 — Business Rules & Services

Goal: Centralize rules and calculations.

Services (under `app/services`):
- `TimeOff::OverlapChecker` — determines overlap for a user/date range against pending/approved requests.
- `TimeOff::AccrualPolicy` — enforces rolling 12-month vacation limits (enterprise-wide). Configurable limit constant (e.g., 160 hours or 20 days) — document assumption.
- `TimeOff::SubmitRequest` — orchestrates validations, creates `TimeOffRequest` (status: pending), optionally creates `Approval` placeholder.
- `TimeOff::Decision` — approves/denies requests (sets `status`, creates/updates `Approval`, sets `decided_at`), triggers notifications.

Model hooks vs services:
- Keep models slim; validations use services where needed (e.g., custom validator that calls `OverlapChecker`).

Acceptance:
- Overlap prevention works; requests in past rejected.
- Vacation limit rule enforced for `TimeOffType.name == 'vacation'`.

---

## Phase 7 — Notifications (Mailers + Jobs)

Goal: Simulate email notifications on submit/decision.

Steps:
- Mailer: `app/mailers/time_off_mailer.rb` with methods `request_submitted(user, request)` and `request_decided(user, request)`.
- Previews under `test/mailers/previews`.
- Jobs using ActiveJob (Solid Queue backend already in Gemfile):
  - `NotifyManagerJob` enqueued on submit (emails manager/admin).
  - `NotifyEmployeeDecisionJob` enqueued on approval/denial.

Acceptance:
- Jobs enqueue and run locally (`bin/rails solid_queue:start` or inline in dev).
- Emails render and log to development log.

---

## Phase 8 — Admin Basics

Goal: Provide a lightweight admin interface without bringing in an admin framework.

Steps:
- Namespaced controllers/views under `Admin::Users`, `Admin::Departments` (CRUD minimal forms).
- Protect with `current_user.admin?` (or Pundit `admin_only`).

Acceptance:
- Admin can create employees, assign manager/department.

---

## Phase 9 — Authentication UX

Goal: Make login/logout flows usable with Clearance.

Steps:
- Ensure Clearance views are present; style with Tailwind.
- Add nav bar: sign in/out links; show current user name/role.

Acceptance:
- Sign in/out works; redirects to dashboard.

---

## Phase 10 — Tests

Goal: Cover models, requests, and basic flows.

Option A — Keep Minitest (fastest with current repo):
- Add model tests for `TimeOffRequest` validations and services.
- Add request tests for API endpoints.
- Add system tests for the main HTML flow (employee submit, manager approve).

Option B — Add RSpec (aligns with requirement):
- Gemfile: `group :development, :test do gem 'rspec-rails' end`
- `bundle install`
- `bin/rails generate rspec:install`
- Add specs mirroring the above. Keep Minitest temporarily or remove once parity exists.

Acceptance:
- Test suite runs green locally.

---

## Phase 11 — Documentation

Goal: Provide API docs and setup instructions.

Steps:
- Add `docs/api.md` with request/response examples for each endpoint (or integrate Swagger via `rswag` if desired).
- Update `README.md` with: setup, running, background jobs, seeds, and notes on AI assistance and trade-offs.

Acceptance:
- Clear instructions for running the app and using the API.

---

## Phase 12 — Polishing and CI (Optional)

Steps:
- Add RuboCop config `.rubocop.yml` using `rubocop-rails-omakase`.
- Tidy views with partials and helpers.

Acceptance:
- CI passes; codebase consistent.

---

## File/Change Checklist by Phase

Quick checklist for agents to track progress.

- Phase 1
  - db/migrate/*: users add fields; create departments, time_off_types, time_off_requests, approvals
  - app/models: department.rb, time_off_type.rb, time_off_request.rb, approval.rb, update user.rb
- Phase 2
  - db/seeds.rb updates; ensure seed load
- Phase 3
  - Gemfile (pundit optional); app/policies/*; ApplicationController includes Pundit
- Phase 4
  - config/routes.rb: resources and namespaces
  - app/controllers/*: time_off_requests, approvals, admin/*, manager/*
  - app/views/time_off_requests/* and layouts/nav
- Phase 5
  - app/controllers/api/v1/*
  - app/views/api/v1/* (Jbuilder) or app/serializers/* (jsonapi-serializer)
  - token auth in API base controller
- Phase 6
  - app/services/time_off/* service objects; custom validators if used
- Phase 7
  - app/mailers/time_off_mailer.rb; jobs in app/jobs/*; previews in test/mailers/previews
- Phase 8
  - admin controllers/views
- Phase 9
  - clearance views styled; application layout/nav updates
- Phase 10
  - tests/specs covering models, requests, and system flows
- Phase 11
  - docs/api.md; README.md updates
- Phase 12
  - .rubocop.yml; .github/workflows/ci.yml

---

## Implementation Notes and Assumptions

- JSON:API compliance is approximated; for strict compliance, prefer `jsonapi-serializer`.
- Vacation limit: define a constant, e.g., `VACATION_LIMIT_DAYS = 20` in `TimeOff::AccrualPolicy`, and compute over a rolling 12-month lookback window using SQL sums on approved vacation requests.
- Overlap rule considers pending and approved requests as blocking new pending approvals.
- Notifications are simulated via ActionMailer previews and development log; no external provider.
- Use Clearance’s `remember_token` as a simple API token if needed, passed via `X-Auth-Token` header. Rotate/regenerate via sign out/in.
- Tailwind is used instead of Bootstrap to match the repo; Flowbite CSS exists under `vendor/` and can be used for UI components.

---

## Quickstart Commands (Developer Workflow)

- Setup:
  - `bin/setup`
  - `bin/rails db:create db:migrate db:seed`
- Run app:
  - `bin/rails server`
  - `bin/rails solid_queue:start` (in a separate terminal for jobs)
- Lint/Security:
  - `bundle exec rubocop`
  - `bundle exec brakeman`
- Tests:
  - Minitest: `bin/rails test`
  - RSpec (if enabled): `bundle exec rspec`


