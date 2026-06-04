enum BackendMode { render, mock, local }

const String defaultRenderHost = 'anne-boleyn-the-pangolin-huqk.onrender.com';

class Env {
  static final BackendMode backend = _parseBackend(
    const String.fromEnvironment('BACKEND', defaultValue: 'render'),
  );

  static final String apiHost = const String.fromEnvironment(
    'API_HOST',
    defaultValue: defaultRenderHost,
  );

  static final int? apiPort = _parsePort(
    const String.fromEnvironment('API_PORT'),
  );

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
