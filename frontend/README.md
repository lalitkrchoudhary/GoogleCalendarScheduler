# Calendar Scheduler - Flutter Frontend

Flutter application for the Google Calendar Scheduler with role-based dashboards and booking management.

## ⚠️ Prerequisites

### Install Flutter

Flutter is required to run this app. If you haven't installed it yet, see [FLUTTER_INSTALLATION.md](../../FLUTTER_INSTALLATION.md) in the root directory.

Verify installation:
```bash
flutter doctor
```

### Backend Setup

Make sure the Django backend is running on `http://localhost:8000`. See [backend/README.md](../../backend/README.md) for setup instructions.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Mobile (Android/iOS):**
```bash
# Make sure an emulator is running or device is connected
flutter devices

# Run on connected device
flutter run
```

## 📱 Screens Implemented

### ✅ Authentication
- **Login Screen** - User login with JWT
- **Register Screen** - User registration with role selection

### ✅ User Dashboard
- Welcome card with user info
- Quick actions (Book Meeting, My Bookings, View Admins, Settings)
- Upcoming meetings list (placeholder)

### ✅ Admin Dashboard
- Admin welcome card
- Statistics cards (Today, This Week, Total, Pending)
- Quick actions (Set Availability, View Bookings)
- Today's schedule (placeholder)

### 🔄 Coming Soon
- Book Meeting Screen
- Available Slots View
- My Bookings List
- Booking Details
- Admin Availability Management
- Admin Bookings View
- Settings & Profile

## 🏗️ Project Structure

```
lib/
├── config/
│   ├── api_config.dart       # API endpoints configuration
│   └── theme.dart             # App theme (light/dark mode)
├── models/
│   ├── user.dart              # User model
│   ├── availability.dart      # Availability & TimeSlot models
│   └── booking.dart           # Booking model
├── providers/
│   └── auth_provider.dart     # Authentication state management
├── services/
│   ├── api_service.dart       # HTTP client with JWT handling
│   └── auth_service.dart      # Authentication service
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── user/
│   │   └── user_dashboard.dart
│   └── admin/
│       └── admin_dashboard.dart
└── main.dart                  # App entry point
```

## 🎨 Features

### State Management
- **Provider** - Simple and efficient state management
- `AuthProvider` for authentication state

### API Integration
- **Dio** HTTP client with interceptors
- Automatic JWT token refresh
- Secure token storage using `flutter_secure_storage`
- Error handling and retry mechanism

### UI/UX
- **Material 3** design
- Light and dark mode support
- Responsive layouts
- Form validation
- Loading states
- Error messages

### Security
- Secure token storage
- Password visibility toggle
- Auto-login on app start
- Token expiry handling

## 🔧 Configuration

### Change API URL

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url/api';
  // ...
}
```

For production, use your deployed backend URL.

### Theme Customization

Edit `lib/config/theme.dart` to customize colors and styles.

## 📦 Dependencies

```yaml
# Core
flutter
provider: ^6.1.1

# HTTP & API
dio: ^5.4.0
http: ^1.2.0

# Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0

# Date & Time
intl: ^0.19.0
timezone: ^0.9.2
flutter_timezone: ^1.0.8

# UI
table_calendar: ^3.0.9
url_launcher: ^6.2.4
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Chrome, Safari, Firefox, Edge)
- ✅ macOS (10.14+)
- ✅ Windows (Windows 10+)
- ✅ Linux

## 🔐 User Roles

### User
- Login/Register
- View available admins
- Book meetings
- View bookings
- Cancel/reschedule meetings

### Admin
- All user features
- Set availability
- View bookings calendar
- Manage schedule

### Super Admin
- All admin features
- User management
- System-wide analytics

## 🏃‍♂️ Development

### Hot Reload
Press `r` in the terminal to hot reload while the app is running.

### Full Restart
Press `R` in the terminal for a full restart.

### Debug Mode
The app runs in debug mode by default. For production:

```bash
# Build for web
flutter build web

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 🐛 Troubleshooting

### "Could not connect to backend"
- Ensure Django backend is running on port 8000
- Check API URL in `api_config.dart`
- Verify CORS settings in Django

### "Token expired"
- The app automatically refreshes tokens
- If refresh fails, you'll be logged out
- Simply login again

### Flutter doctor issues
```bash
flutter doctor -v
```
Follow the instructions to fix any issues.

## 📝 TODO

High Priority:
- [ ] Book Meeting Screen
- [ ] Time Slot Selection
- [ ] My Bookings List
- [ ] Booking Details
- [ ] Admin Availability Management

Medium Priority:
- [ ] Notifications
- [ ] Calendar View
- [ ] Search & Filter
- [ ] Profile Settings

Low Priority:
- [ ] Dark mode toggle
- [ ] Export to CSV
- [ ] Offline support
- [ ] Push notifications

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

MIT License

---

**Status**: 🚧 Core Features Complete | Advanced Features In Progress

**Note**: Make sure to install Flutter first (see [FLUTTER_INSTALLATION.md](../../FLUTTER_INSTALLATION.md))
