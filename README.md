# README

Employee Time-Off Tracking System (Rails 8)

Quickstart
- Requirements: Ruby 3.4.1 (see `.ruby-version`), Bundler 2.6.x, SQLite3
- Setup:
  - `rbenv install 3.4.1 && rbenv local 3.4.1`
  - `gem install bundler:2.6.2`
  - `bundle install`
  - `bin/rails db:create db:migrate db:seed`
- Run:
  - `bin/rails server`
  - `bin/rails solid_queue:start` in a second terminal (for background jobs)

Seed Users
- admin@example.com / password (admin)
- manager@example.com / password (manager)
- employee@example.com / password (employee)

API
- See `docs/api.md` for endpoints and examples.

Notes
- Auth: Clearance
- Background jobs: ActiveJob + Solid Queue
- UI: Haml + Tailwind

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
