# Eat Me First - Grocery Expiry Tracker

A modern Flutter application designed to help users track and manage their grocery items' expiration dates efficiently.

## Features

- Track grocery items and their expiration dates
- Smart dashboard with expiry statistics
- Delivery status tracking
- Dark theme optimized for iPad and larger screens
- Responsive design that works on mobile and tablets
- Local data storage with web browser support

## Technical Details

- Framework: Flutter
- Language: Dart
- Storage: Hive (local storage with web IndexedDB support)
- Platforms: Web, iOS, Android
- Dark theme with Material 3 design

## Getting Started

1. Make sure you have Flutter installed
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- flutter: latest
- hive: ^2.2.3
- hive_flutter: ^1.1.0
- uuid: ^4.3.3
- intl: ^0.19.0

## Version History

### Current Development (v1.1.0-dev)
- Added sorting functionality:
  - Sort by expiry date (default)
  - Sort by item name
  - Toggle ascending/descending order
- Improved date display:
  - Added day of the week to expiry dates
  - More readable date format (e.g., "Monday, 27 November 2024")
- Work in progress...

### v1.0.0
Initial release with core features:
- Grocery item management
- Expiration date tracking
- Delivery status tracking
- Dark theme
- iPad-optimized UI
- Local storage
