# pangolin_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Switching backend implementations

This app supports selecting which implementation to use at runtime via
compile-time environment variables. Use `flutter run` (or `flutter build`)
with `--dart-define` to choose the backend.

- Use the mock implementations (no network):

```bash
flutter run --dart-define=BACKEND=mock
```

- Use the Render/real API implementation (default):

```bash
flutter run --dart-define=BACKEND=render
```

- Override the API host used by the Render implementation:

```bash
flutter run --dart-define=BACKEND=render --dart-define=API_HOST=your-host.example.com
```

Notes:
- The app reads `BACKEND` and `API_HOST` via `const String.fromEnvironment`.
- Dependency wiring is performed in `lib/config/service_locator.dart`.

