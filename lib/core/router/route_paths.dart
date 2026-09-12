class RoutePaths {
  RoutePaths._();

  // Public / Unauthenticated
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String otp = '/otp';

  // Protected application routes
  static const String dashboard = '/';
  static const String systemStatus = '/system-status';
  static const String componentShowcase = '/components';
  static const String changePassword = '/change-password';
  static const String firstLoginChangePassword = '/first-login-change-password';
  static const String sessions = '/sessions';
  static const String loginHistory = '/login-history';
}
