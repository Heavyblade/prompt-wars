# API v1

Auth: send `X-Auth-Token` header with the user’s `remember_token` (Clearance). For testing, sign in via UI and capture the token in the DB.

Base path: `/api/v1`

Endpoints
- `GET /time_off_requests`
  - Employee: own requests; Manager: team; Admin: all
  - 200: JSON array of requests

- `GET /time_off_requests/:id`
  - Access if owner, manager of owner, or admin
  - 200: request JSON
  - 403 if unauthorized

- `POST /time_off_requests`
  - Body:
    `{ "time_off_request": { "time_off_type_id": 1, "start_date": "2025-09-10", "end_date": "2025-09-12", "reason": "Vacation" } }`
  - 201: created JSON
  - 422: `{ errors: [ ... ] }`

- `POST /time_off_requests/:id/approve`
  - Manager of owner or Admin
  - 200: updated JSON
  - 403 if unauthorized

- `POST /time_off_requests/:id/deny`
  - Manager of owner or Admin
  - 200: updated JSON
  - 403 if unauthorized

Response Fields
- id, user_id, time_off_type_id, start_date, end_date, reason, status
- Includes `time_off_type.name` in some responses

