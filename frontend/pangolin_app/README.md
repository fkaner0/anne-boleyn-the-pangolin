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
flutter run --dart-define=BACKEND=local --dart-define=API_PORT=8080
```

The `local` backend talks to a backend running on your machine over plain
HTTP (it does not use HTTPS). Point it at the local server with `API_HOST`
and `API_PORT`:

```bash
flutter run --dart-define=BACKEND=local --dart-define=API_HOST=localhost --dart-define=API_PORT=8080
```


- Override the API host used by the Render implementation:

```bash
flutter run --dart-define=BACKEND=render --dart-define=API_HOST=your-host.example.com
```

- Override the API port (mainly useful with `BACKEND=local`):

```bash
flutter run --dart-define=BACKEND=local --dart-define=API_PORT=8080
```


Notes:
- The app reads `BACKEND`, `API_HOST`, and `API_PORT` via
  `const String.fromEnvironment`.
- `API_PORT` is optional; when unset the port is omitted from the request URL.
- The `render` backend uses HTTPS, while the `local` backend uses HTTP.
- Dependency wiring is performed in `lib/config/service_locator.dart`.

