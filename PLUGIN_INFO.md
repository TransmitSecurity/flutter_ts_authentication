# Flutter TS Authentication Plugin

Production-ready Flutter plugin for Transmit Security Authentication.

## Build Info
- Built: Sun Sep 27 14:29:23 UTC 2026
- Version: 0.0.5
- Commit: a46202a
- Flutter: Flutter 3.41.9 • channel stable • https://github.com/flutter/flutter.git

## Installation

Add to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  flutter_ts_authentication:
    git:
      url: https://github.com/TransmitSecurity/flutter_ts_authentication.git
      ref: 0.0.5
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

// Or initialize with parameters. `domain` is an origin, including the https:// scheme.
await tsAuth.initialize(
  'your-client-id',
  'https://your-domain.com',
  'https://api.transmitsecurity.io/',
  null,
);
```
