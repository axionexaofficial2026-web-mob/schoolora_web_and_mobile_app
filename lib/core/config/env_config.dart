enum Environment { development, staging, production }

class EnvConfig {
  EnvConfig._();

  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static Environment get currentEnvironment {
    switch (_envName.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  static bool get isProduction => currentEnvironment == Environment.production;
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;

  /// Dynamic base URL override if updated at runtime (e.g. testing or settings)
  static String? _overrideApiBaseUrl;

  static void setApiBaseUrl(String url) {
    _overrideApiBaseUrl = url;
  }

  static void resetApiBaseUrl() {
    _overrideApiBaseUrl = null;
  }

  static String get apiBaseUrl => _overrideApiBaseUrl ?? _apiBaseUrl;

  static const String appName = 'Schoolaora ERP';
  static const String appVersion = '1.0.0';
  static const String apiVersion = 'v1';
}
