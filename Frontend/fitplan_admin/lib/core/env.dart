/// Where the API is, and which environment the header names. Set at build time:
/// `--dart-define=API_BASE_URL=... --dart-define=ADMIN_ENV=Dev`
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:5264');

  /// "Production", "Dev" or "Local", shown on every screen so a Production action is never a surprise.
  static const name = String.fromEnvironment('ADMIN_ENV', defaultValue: 'Local');
}
