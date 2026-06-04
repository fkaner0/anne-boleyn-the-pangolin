# pangolin_app

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

-- Run on localhost entirely

```bash
flutter run --dart-define=BACKEND=local
```


- Override the API host used by the Render implementation:

```bash
flutter run --dart-define=BACKEND=render --dart-define=API_HOST=your-host.example.com
```


Notes:
- The app reads `BACKEND` and `API_HOST` via `const String.fromEnvironment`.
- Dependency wiring is performed in `lib/config/service_locator.dart`.

