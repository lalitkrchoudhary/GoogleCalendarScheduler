# Google Calendar Scheduler - Backend

Django REST API for the Google Calendar Scheduler application.

## Features

- ✅ User Authentication (JWT)
- ✅ Role-based Access Control (User/Admin/SuperAdmin)
- ✅ Availability Management
- ✅ Booking System with Conflict Detection
- ✅ Time Zone Support
- ✅ RESTful API Endpoints
- 🔄 Google Calendar Integration (Coming Soon)
- 🔄 Email Notifications (Coming Soon)
- 🔄 WhatsApp Notifications (Coming Soon)

## Tech Stack

- **Framework**: Django 5.0.1
- **API**: Django REST Framework 3.14.0
- **Authentication**: JWT (djangorestframework-simplejwt)
- **Database**: SQLite (for development)
- **CORS**: django-cors-headers

## Setup Instructions

### 1. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Environment Variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

### 4. Run Migrations

```bash
python manage.py migrate
```

### 5. Create Superuser

```bash
python manage.py createsuperuser
```

Follow the prompts to create an admin account.

### 6. Run Development Server

```bash
python manage.py runserver
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Authentication (`/api/auth/`)

- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `POST /api/auth/token/refresh/` - Refresh JWT token
- `GET /api/auth/me/` - Get current user profile
- `PATCH /api/auth/me/` - Update current user profile
- `POST /api/auth/change-password/` - Change password
- `GET /api/auth/` - List all users (role-based)
- `GET /api/auth/admins/` - List all admin users

### Availability (`/api/availability/`)

- `GET /api/availability/` - List availabilities
- `POST /api/availability/` - Create availability (Admin only)
- `GET /api/availability/{id}/` - Get availability detail
- `PATCH /api/availability/{id}/` - Update availability
- `DELETE /api/availability/{id}/` - Delete availability
- `GET /api/availability/slots/` - Get available time slots

### Bookings (`/api/bookings/`)

- `GET /api/bookings/` - List bookings
- `POST /api/bookings/` - Create booking
- `GET /api/bookings/{id}/` - Get booking detail
- `PATCH /api/bookings/{id}/` - Update booking
- `DELETE /api/bookings/{id}/` - Delete booking
- `POST /api/bookings/{id}/cancel/` - Cancel booking
- `POST /api/bookings/{id}/reschedule/` - Reschedule booking
- `GET /api/bookings/dashboard/user/` - User dashboard
- `GET /api/bookings/dashboard/admin/` - Admin dashboard

## API Usage Examples

### Register a User

```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "user@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "role": "user",
    "timezone": "America/New_York"
  }'
```

### Login

```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "SecurePass123!"
  }'
```

### Create Availability (Admin)

```bash
curl -X POST http://localhost:8000/api/availability/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "date": "2026-01-15",
    "start_time": "09:00:00",
    "end_time": "17:00:00",
    "slot_duration": 30
  }'
```

### Get Available Time Slots

```bash
curl -X GET "http://localhost:8000/api/availability/slots/?admin=1&date=2026-01-15" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Create Booking

```bash
curl -X POST http://localhost:8000/api/bookings/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "admin": 1,
    "date": "2026-01-15",
    "start_time": "10:00:00",
    "end_time": "10:30:00",
    "timezone": "America/New_York",
    "meeting_purpose": "Project discussion"
  }'
```

## Database Models

### User
- Extended Django User with role field (user/admin/superadmin)
- Timezone support
- Google Calendar OAuth token storage
- Phone number for WhatsApp

### Availability
- Admin availability slots
- Date and time range
- Configurable slot duration (15/30/60 minutes)
- Auto-generates time slots

### Booking
- Meeting booking with user and admin
- Date, time, and timezone
- Meeting purpose and notes
- Google Calendar event ID
- Status (pending/confirmed/cancelled)
- Conflict prevention with unique constraints

## Admin Interface

Access the Django admin at `http://localhost:8000/admin/` with your superuser credentials.

## Testing

```bash
python manage.py test
```

## Next Steps

1. Implement Google Calendar Integration
2. Set up Celery for scheduled tasks
3. Implement Email Notifications
4. Add WhatsApp Integration
5. Export Reports to CSV
6. Deploy to production

## License

MIT License
