enum BackendMode { render, mock, local }

const String defaultRenderHost = 'anne-boleyn-the-pangolin-huqk.onrender.com';
const String defaultLocalHost = 'localhost';
const int defaultLocalPort = 8080;

class Env {
  static final BackendMode backend = _parseBackend(
    const String.fromEnvironment('BACKEND', defaultValue: 'render'),
  );

  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static final int? _portOverride = _parsePort(
    const String.fromEnvironment('API_PORT'),
  );

  static String get renderHost =>
      _hostOverride.isEmpty ? defaultRenderHost : _hostOverride;

  static int? get renderPort => _portOverride;

  static String get localHost =>
      _hostOverride.isEmpty ? defaultLocalHost : _hostOverride;

  static int? get localPort => _portOverride ?? defaultLocalPort;

  static int? _parsePort(String value) =>
      value.isEmpty ? null : int.tryParse(value);

  static BackendMode _parseBackend(String value) {
    switch (value.toLowerCase()) {
      case 'mock':
        return BackendMode.mock;
      case 'local':
        return BackendMode.local;
      default:
        return BackendMode.render;
    }
  }
}
