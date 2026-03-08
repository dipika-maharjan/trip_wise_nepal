# TripWise Nepal

TripWise Nepal is a Flutter-based travel and booking app for exploring and booking eco-friendly accommodations in Nepal. It includes full user authentication, onboarding, accommodation discovery, trip bookings with eSewa integration, and profile management.

## Features

- **Authentication & Onboarding**
	- Email/password registration and login
	- Password reset via email link (deep link support)
	- Splash screen that routes to dashboard or onboarding based on login state
	- Simple onboarding flow with marketing copy and skip to login

- **Dashboard**
	- Bottom navigation with tabs for Home, Accommodations, Bookings, and Profile
	- Home tab shows highlighted accommodations and user trips overview

- **Accommodations**
	- Paginated accommodation list with search and price filters
	- Detailed accommodation view with:
		- Photos, description, amenities, eco highlights
		- Room types and optional extras
		- Map view with distance from user location
		- Reviews (view/add/edit/delete)

- **Bookings**
	- Create new bookings from an accommodation detail screen
	- Select dates, guests, room types, and optional extras
	- Total price calculation based on selections
	- eSewa payment integration via WebView
	- Pay-later option
	- Booking list ("My Bookings") with detail view
	- Edit or cancel bookings with rules based on payment status

- **Profile & Settings**
	- View profile with name, email, and avatar
	- Edit profile details
	- Upload and update profile picture (with local persistence)
	- Settings screen with theme toggle (light/dark)
	- Change password screen and logout flow

- **Offline / Persistence**
	- Hive for secure auth/session persistence
	- SharedPreferences for lightweight session flags

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Feature-first, layered (presentation → domain → data)
- **State Management**: Riverpod (Notifier providers)
- **Networking**: Dio-based API client
- **Local Storage**:
	- Hive for auth/session data
	- SharedPreferences for simple key/value flags
- **Location & Maps**:
	- geolocator, flutter_map, latlong2
- **Media & Permissions**:
	- image_picker, permission_handler
- **Payments**:
	- eSewa integration via webview_flutter

## Project Structure

High-level structure:

- `lib/`
	- `main.dart` – app entrypoint, initializes Hive and SharedPreferences
	- `app.dart` – MaterialApp, theming, routes, deep link handling
	- `core/` – shared code (API client, config, constants, error handling, services)
	- `features/`
		- `auth/` – login/register/reset password, domain & data layers
		- `onboarding/` – onboarding screens
		- `splash/` – splash screen and initial routing
		- `dashboard/` – bottom navigation and home tab
		- `accommodation/` – list/detail, usecases, repositories, view models
		- `booking/` – booking list/form/detail, eSewa webview, domain & data
		- `profile/` – profile, edit profile, settings, change password, view model
	- `app/routes/` – central route definitions
	- `app/theme/` – app themes and theme provider

- `assets/`
	- `images/` – onboarding, accommodation, and other images
	- `icons/` – custom icons
	- `fonts/` – custom font families

- `test/`
	- `features/**` – unit and widget tests organized by feature
	- View model tests using Riverpod `ProviderContainer`

## Getting Started

### Prerequisites

- Flutter SDK installed (see [Flutter installation](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code with Flutter/Dart plugins
- An emulator or physical device (Android or iOS)

### Install Dependencies

From the project root:

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

You can also specify a device:

```bash
flutter run -d emulator-5554
```

## Testing

This project includes unit tests for domain use cases, view model tests, and widget tests for key screens.

Run the full test suite:

```bash
flutter test
```

You can run a specific test file, for example:

```bash
flutter test test/features/profile/presentation/view_model/profile_viewmodel_test.dart
```

## Configuration Notes

- API base URLs and environment-specific configuration are defined in the core config layer.
- eSewa payment integration is handled via a WebView page in the booking feature.
- Deep links (e.g., for password reset) are wired through the app entry and route handling.