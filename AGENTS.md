# AGENTS.md — Working Effectively on This Rails App

This document orients AI agents and contributors to make correct, minimal, and testable changes in this Rails project.

## Stack & Conventions

- Ruby/Rails: Ruby `3.4.1`, Rails 8 (omakase defaults).
- Auth: `clearance`. Sign-in route `GET /sign_in`.
- Views: Haml (`haml-rails`) + Tailwind. Prefer `.html.haml` over ERB.
- Jobs: ActiveJob + `solid_queue` with Mission Control Jobs UI at `/jobs`.
- Linting: `rubocop` with `rubocop-rails-omakase` config.
- Tests: Minitest (`bin/rails test`). Mailer previews under `test/mailers/previews`.
- JSON API: Simple JSON via controllers; some docs under `docs/api.md`.

## Setup & Run

- Requirements: Ruby `3.4.1` (`.ruby-version`), Bundler `2.6.x`, SQLite3.
- Install:
  - `rbenv install 3.4.1 && rbenv local 3.4.1`
  - `gem install bundler:2.6.2`
  - `bundle install`
  - `bin/rails db:create db:migrate db:seed`
- Run app:
  - `bin/rails server`
  - `bin/rails solid_queue:start` in another terminal to process jobs
- Dev tooling:
  - Tailwind watcher: `bin/rails tailwindcss:watch` (see `Procfile.dev`)
  - Lint: `bin/rubocop`
  - Tests: `bin/rails test`

## Development Workflow (for Agents)

- Prefer surgical changes: fix the root cause without broad refactors.
- Match existing style: Haml for views, service objects in `app/services/time_off/*`.
- When adding UI, use Tailwind utility classes and existing helpers (see `app/helpers`).
- For background work, prefer `deliver_later` and jobs enqueued via ActiveJob.
- Keep API controllers lean; reuse service objects for business rules.
- If you add files, follow Rails conventions so autoloading works; keep namespaced code in matching folders.
- Update or add previews for new mailers under `test/mailers/previews`.

## Project Structure Highlights

- `app/controllers`:
  - Web controllers (HTML) and namespaced admin/manager controllers.
  - API: `app/controllers/api/v1/*` (JSON only; token auth via `X-Auth-Token`).
- `app/mailers`: `ApplicationMailer` uses `layouts/mailer.*.haml`. Place templates in `app/views/<mailer>/<action>.(html|text).haml`.
- `app/services/time_off`:
  - `SubmitRequest` — validations + creation (calls accrual policy).
  - `Decision` — approve/deny logic, updates `Approval`.
  - `OverlapChecker` — prevents overlapping requests.
  - `AccrualPolicy` — rolling 12‑month vacation limit (20 days default).
- `app/jobs`:
  - `NotifyManagerJob` — email manager on submit.
  - `NotifyEmployeeDecisionJob` — email employee on decision.
- `app/views`:
  - Haml templates with Tailwind. Shared layout/nav in `app/views/layouts`.
- `docs/api.md` — public API endpoints and shapes.

## Domain Model (abridged)

- `User` has `role` enum: `employee`, `manager`, `admin`. Managers have `direct_reports`.
- `TimeOffRequest` belongs to `user` and `time_off_type`; `status` enum: `pending`, `approved`, `denied`.
- `Approval` belongs to `time_off_request` (set by `TimeOff::Decision`).
- `TimeOffType` seeded with common types.

## Background Jobs & Mailers

- Queue adapter: `solid_queue` (see `config/environments/*`). Start workers via `bin/rails solid_queue:start`.
- Jobs UI: visit `/jobs` (Mission Control Jobs) to inspect queues and retries.
- Mailers:
  - Layouts: `app/views/layouts/mailer.html.haml` and `mailer.text.haml`.
  - Templates live in `app/views/<mailer_name>/<action>.(html|text).haml`.
  - Add previews in `test/mailers/previews/*_preview.rb` for quick inspection.

## API Notes (v1)

- Auth: header `X-Auth-Token` equals the user’s `remember_token` (Clearance).
- Base path: `/api/v1`.
- Endpoints for `time_off_requests`: index/show/create; `approve`/`deny` member actions (see `docs/api.md`).
- Authorization rules mirror the HTML app: managers can act on direct reports; admins can access all.

## Testing & Quality

- Run tests: `bin/rails test`.
- Prefer writing new tests near existing Minitest files under `test/` if needed.
- Lint: `bin/rubocop` (uses `.rubocop.yml` with Rails omakase settings).

## Common Tasks & Examples

- Add a mailer action:
  1) Define in `app/mailers/xyz_mailer.rb` and call `mail(...)`.
  2) Create `app/views/xyz_mailer/<action>.html.haml` and `.text.haml`.
  3) Add a preview in `test/mailers/previews/xyz_mailer_preview.rb`.

- Add a service:
  - Place under `app/services/<namespace>/your_service.rb`.
  - Keep controllers thin; call service from controller or job.

- Modify UI:
  - Use Haml with Tailwind utility classes; update shared components in `app/views/layouts` or helpers in `app/helpers`.

## Gotchas

- Views are Haml-first. Avoid adding ERB templates alongside Haml unless converting.
- Mailers require matching templates; missing templates cause `ActionView::MissingTemplate` errors.
- Background jobs require the worker process running; otherwise `deliver_later` won’t send emails in development.
- API controllers use token auth and do not include browser concerns from `ApplicationController`.

## Seed Data

- After `db:seed`, you have:
  - `admin@example.com` / `password` (admin)
  - `manager@example.com` / `password` (manager)
  - `employee@example.com` / `password` (employee)
  - Default `TimeOffType` entries (Vacation, Sick, Personal)

## Contribution Guidelines (for Agents)

- Keep changes minimal and scoped to the task; don’t refactor unrelated code.
- Follow file naming and module/namespace conventions so Zeitwerk autoloading works.
- Prefer adding dedicated service objects for business logic over fat controllers/models.
- When adding new endpoints, mirror existing patterns (auth, role checks, response shapes).
- If you must introduce new libs, justify them and keep Gemfile diff small.

