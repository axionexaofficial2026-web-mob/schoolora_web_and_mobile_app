import 'package:flutter/foundation.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';
import 'view_state.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repository;

  AuthProvider(this._repository);

  ViewState _state = ViewState.initial;
  AuthenticatedUser? _currentUser;
  AppException? _error;
  String? _successMessage;

  bool _isAuthenticated = false;
  bool _mustChangePassword = false;
  bool _emailVerified = false;
  bool _sessionExpired = false;

  List<AuthSessionItem> _sessions = [];
  List<LoginHistoryItem> _loginHistory = [];

  // Getters
  ViewState get state => _state;
  AuthenticatedUser? get currentUser => _currentUser;
  AppException? get error => _error;
  String? get successMessage => _successMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isRefreshing => _state == ViewState.refreshing;

  bool get isAuthenticated => _isAuthenticated;
  bool get mustChangePassword => _mustChangePassword;
  bool get emailVerified => _emailVerified;
  bool get sessionExpired => _sessionExpired;

  List<AuthSessionItem> get sessions => List.unmodifiable(_sessions);
  List<LoginHistoryItem> get loginHistory => List.unmodifiable(_loginHistory);

  /// Initializes auth state on startup by checking persisted credentials
  Future<void> initialize() async {
    final hasTokens = await _repository.hasStoredTokens();
    if (!hasTokens) {
      _isAuthenticated = false;
      _currentUser = null;
      _state = ViewState.initial;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
      _isAuthenticated = true;
      _mustChangePassword = user.mustChangePassword;
      _emailVerified = user.emailVerified;
      _sessionExpired = false;
      _error = null;
      _state = ViewState.success;
    } catch (e) {
      // If unable to load current user (e.g. expired or invalid token)
      await _repository.clearLocalAuth();
      _isAuthenticated = false;
      _currentUser = null;
      _mustChangePassword = false;
      _error = null;
      _state = ViewState.initial;
    } finally {
      notifyListeners();
    }
  }

  /// Sign in with email, password, and optional tenant code
  Future<bool> login({
    required String email,
    required String password,
    String? tenantCode,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    _sessionExpired = false;
    notifyListeners();

    try {
      final result = await _repository.login(
        email: email,
        password: password,
        tenantCode: tenantCode,
      );

      _currentUser = result.user;
      _isAuthenticated = true;
      _mustChangePassword = result.mustChangePassword;
      _emailVerified = result.user.emailVerified;
      _state = ViewState.success;
      _successMessage = 'Welcome back, ${result.user.firstName}!';
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _isAuthenticated = false;
      _currentUser = null;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Complete logout clearing both backend session and secure local tokens
  Future<void> logout() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      await _repository.logout();
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _mustChangePassword = false;
      _sessions = [];
      _loginHistory = [];
      _state = ViewState.initial;
      _error = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Dispatch password reset link to user email
  Future<bool> forgotPassword({
    required String email,
    String? tenantCode,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.forgotPassword(
        email: email,
        tenantCode: tenantCode,
      );
      _successMessage = msg;
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Reset password using one-time token and new password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _successMessage = msg;
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Update password while authenticated
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _successMessage = msg;
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// First login password change required by mustChangePassword flag
  Future<bool> firstLoginChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _mustChangePassword = false;
      _successMessage = msg;
      _state = ViewState.success;

      // Refresh current user info to reflect updated state
      try {
        final updatedUser = await _repository.getCurrentUser();
        _currentUser = updatedUser;
        _mustChangePassword = updatedUser.mustChangePassword;
      } catch (_) {}

      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Verify email with code/token
  Future<bool> verifyEmail({required String token}) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.verifyEmail(token: token);
      _emailVerified = true;
      _successMessage = msg;
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail({
    required String email,
    String? tenantCode,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.resendVerificationEmail(
        email: email,
        tenantCode: tenantCode,
      );
      _successMessage = msg;
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Request one-time password (OTP)
  Future<OtpRequestResponse?> requestOtp({
    required String identifier,
    required OtpPurpose purpose,
    String? tenantCode,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.requestOtp(
        identifier: identifier,
        purpose: purpose,
        tenantCode: tenantCode,
      );
      _successMessage = result.message ?? 'OTP dispatched successfully.';
      _state = ViewState.success;
      notifyListeners();
      return result;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return null;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp({
    required String identifier,
    required OtpPurpose purpose,
    required String code,
  }) async {
    _state = ViewState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.verifyOtp(
        identifier: identifier,
        purpose: purpose,
        code: code,
      );
      _successMessage = result.message ?? 'OTP verified successfully.';
      _state = ViewState.success;
      notifyListeners();
      return result.verified;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Fetch active sessions
  Future<void> fetchSessions() async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    try {
      final list = await _repository.getSessions();
      _sessions = list;
      _state = ViewState.success;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Revoke single session
  Future<bool> revokeSession(String sessionId) async {
    try {
      await _repository.revokeSession(sessionId);
      await fetchSessions();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      notifyListeners();
      return false;
    }
  }

  /// Revoke all other sessions
  Future<bool> revokeAllSessions({bool preserveCurrentSession = true}) async {
    try {
      await _repository.revokeAllSessions(
        preserveCurrentSession: preserveCurrentSession,
      );
      await fetchSessions();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      notifyListeners();
      return false;
    }
  }

  /// Fetch login audit history
  Future<void> fetchLoginHistory({int limit = 20, int offset = 0}) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    try {
      final list = await _repository.getLoginHistory(
        limit: limit,
        offset: offset,
      );
      _loginHistory = list;
      _state = ViewState.success;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Session expiration hook triggered by Dio ApiInterceptor
  void handleSessionExpired() {
    _isAuthenticated = false;
    _currentUser = null;
    _mustChangePassword = false;
    _sessionExpired = true;
    _error = const UnauthorizedException(
      message: 'Your session has expired. Please sign in again.',
      code: 'SESSION_EXPIRED',
    );
    notifyListeners();
  }

  void clearSessionExpiredFlag() {
    _sessionExpired = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}
