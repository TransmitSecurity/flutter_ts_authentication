# Flutter TS Authentication Plugin

Production-ready Flutter plugin for Transmit Security Authentication.

## Build Info
- Built: Tue Feb 17 12:16:15 EST 2026
- Commit: a22f007
- Flutter: Flutter 3.38.3 • channel stable • https://github.com/flutter/flutter.git

## Installation

Add to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  flutter_ts_authentication:
    git:
      url: https://github.com/TransmitSecurity/flutter_ts_authentication.git
      ref: v  # Use the latest version tag
```

Then run:
```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter_ts_authentication/flutter_ts_authentication.dart';

final tsAuth = FlutterTsAuthentication();

// Initialize SDK
await tsAuth.initializeSDK();

// Initialize with parameters
await tsAuth.initialize('client-id', 'domain', 'base-url');
```
