class AppConstants {
  AppConstants._();

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerCorrelationId = 'x-correlation-id';
  static const String headerTenantId = 'x-tenant-id';
  static const String contentTypeJson = 'application/json';

  // API Endpoints - Foundation
  static const String endpointHealth = '/api/v1/health';
  static const String endpointMeta = '/api/v1/meta';
  static const String endpointPublicConfig = '/api/v1/config/public';

  // API Endpoints - Authentication & Security (Phase 2)
  static const String endpointLogin = '/api/v1/auth/login';
  static const String endpointLogout = '/api/v1/auth/logout';
  static const String endpointRefresh = '/api/v1/auth/refresh';
  static const String endpointForgotPassword = '/api/v1/auth/forgot-password';
  static const String endpointResetPassword = '/api/v1/auth/reset-password';
  static const String endpointChangePassword = '/api/v1/auth/change-password';
  static const String endpointVerifyEmail = '/api/v1/auth/verify-email';
  static const String endpointResendVerificationEmail =
      '/api/v1/auth/resend-verification-email';
  static const String endpointOtpRequest = '/api/v1/auth/otp/request';
  static const String endpointOtpVerify = '/api/v1/auth/otp/verify';
  static const String endpointMe = '/api/v1/auth/me';
  static const String endpointSessions = '/api/v1/auth/sessions';
  static const String endpointSessionsRevokeAll =
      '/api/v1/auth/sessions/revoke-all';
  static const String endpointLoginHistory = '/api/v1/auth/login-history';

  // Pagination defaults
  static const int defaultPageSize = 10;
  static const List<int> pageSizeOptions = [10, 25, 50, 100];
}
