# HRM WebLoad - Flutter App

A Flutter application that provides a mobile interface for the HRM system using WebView.

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── screens/                  # Screen widgets
│   ├── screens.dart         # Screen exports
│   ├── splash_screen.dart   # Animated splash screen
│   └── webview_page.dart    # Main WebView page
├── constants/               # App-wide constants
│   ├── constants.dart      # Constants exports
│   └── app_constants.dart  # Colors, URLs, sizes, etc.
├── utils/                   # Utility functions and helpers
│   ├── utils.dart          # Utils exports
│   └── app_utils.dart      # Navigation, theme, and helper functions
└── widgets/                 # Reusable widgets (future use)
```

## Features

- **Splash Screen**: Animated splash screen with logo scaling and text fade effects
- **WebView Integration**: Loads the HRM system in a mobile-optimized WebView
- **Modern UI**: Material Design 3 with custom theming
- **Error Handling**: Graceful error handling with retry functionality
- **Performance Optimized**: Caching headers and zoom disabled for better performance
- **Cross-Platform**: Supports Android and iOS

## Architecture

- **Separation of Concerns**: Screens, constants, and utilities are properly separated
- **Reusable Components**: Constants and utilities promote code reusability
- **Clean Code**: Well-organized folder structure with clear naming conventions
- **Maintainable**: Easy to extend and modify individual components

## Dependencies

- `webview_flutter`: For WebView functionality
- `flutter/material.dart`: For UI components

## Getting Started

1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. For APK build: `flutter build apk --release`