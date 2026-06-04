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

- Run against a backend on your machine (plain HTTP):

```bash
flutter run --dart-define=BACKEND=local
```

The `local` backend defaults to `localhost:8080` over HTTP, so no other flags
are needed for a standard local server. Override the host and/or port if your
server runs elsewhere:

```bash
flutter run --dart-define=BACKEND=local --dart-define=API_HOST=192.168.0.5 --dart-define=API_PORT=9000
```

- Override the API host used by the Render implementation:

```bash
flutter run --dart-define=BACKEND=render --dart-define=API_HOST=your-host.example.com
```


Notes:
- The app reads `BACKEND`, `API_HOST`, and `API_PORT` via
  `const String.fromEnvironment`.
- Host/port defaults are mode-specific: `render` defaults to the deployed
  Render host over HTTPS; `local` defaults to `localhost:8080` over HTTP.
  `API_HOST` / `API_PORT` override the default for whichever mode is active.
- Dependency wiring is performed in `lib/config/service_locator.dart`.

