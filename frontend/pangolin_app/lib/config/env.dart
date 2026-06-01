enum BackendMode { render, mock, local }

class Env {
  static final BackendMode backend = _parseBackend(
    const String.fromEnvironment('BACKEND', defaultValue: 'render'),
  );

  static final String apiHost =
      const String.fromEnvironment('API_HOST', defaultValue: 'anne-boleyn-the-pangolin-huqk.onrender.com');

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
