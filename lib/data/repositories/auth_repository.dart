import '../../core/errors/app_exception.dart';
import '../../core/security/secure_token_storage.dart';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';

abstract class IAuthRepository {
  Future<LoginResponseData> login({
    required String email,
    required String password,
    String? tenantCode,
  });

  Future<void> logout();

  Future<AuthTokens> refresh();

  Future<String> forgotPassword({required String email, String? tenantCode});

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<String> verifyEmail({required String token});

  Future<String> resendVerificationEmail({
    required String email,
    String? tenantCode,
  });

  Future<OtpRequestResponse> requestOtp({
    required String identifier,
    required OtpPurpose purpose,
    String? tenantCode,
  });

  Future<OtpVerifyResponse> verifyOtp({
    required String identifier,
    required OtpPurpose purpose,
    required String code,
  });

  Future<AuthenticatedUser> getCurrentUser();

  Future<List<AuthSessionItem>> getSessions();

  Future<String> revokeSession(String sessionId);

  Future<int> revokeAllSessions({bool preserveCurrentSession = true});

  Future<List<LoginHistoryItem>> getLoginHistory({
    int limit = 20,
    int offset = 0,
  });

  Future<bool> hasStoredTokens();

  Future<void> clearLocalAuth();
}

class AuthRepository implements IAuthRepository {
  final AuthApiService _apiService;
  final ISecureTokenStorage _tokenStorage;

  AuthRepository(this._apiService, this._tokenStorage);

  @override
  Future<LoginResponseData> login({
    required String email,
    required String password,
    String? tenantCode,
  }) async {
    final response = await _apiService.login(
      email: email,
      password: password,
      tenantCode: tenantCode,
    );

    if (!response.success || response.data == null) {
      throw BadResponseException(
        message: response.error?.message ?? 'Login failed. Please try again.',
        code: response.error?.code ?? 'LOGIN_FAILED',
        details: response.error?.details,
      );
    }

    final data = response.data!;
    // Securely persist tokens
    await _tokenStorage.saveTokens(
      accessToken: data.tokens.accessToken,
      refreshToken: data.tokens.refreshToken,
    );

    return data;
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      await _apiService.logout(refreshToken: refreshToken);
    } catch (_) {
      // If server-side logout fails because session is expired or network is unreachable,
      // we still guarantee local state and tokens are cleared.
    } finally {
      await clearLocalAuth();
    }
  }

  @override
  Future<AuthTokens> refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearLocalAuth();
      throw const UnauthorizedException(
        message: 'No refresh token available.',
        code: 'NO_REFRESH_TOKEN',
      );
    }

    final response = await _apiService.refresh(refreshToken: refreshToken);
    if (!response.success || response.data == null) {
      await clearLocalAuth();
      throw UnauthorizedException(
        message: response.error?.message ?? 'Session expired.',
        code: response.error?.code ?? 'TOKEN_REFRESH_FAILED',
      );
    }

    final tokens = response.data!;
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<String> forgotPassword({
    required String email,
    String? tenantCode,
  }) async {
    final response = await _apiService.forgotPassword(
      email: email,
      tenantCode: tenantCode,
    );

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Password reset request failed.',
        code: response.error?.code ?? 'FORGOT_PASSWORD_FAILED',
      );
    }

    final message =
        response.data?['message']?.toString() ??
        'If an account exists with this email, a password reset link has been dispatched.';
    return message;
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiService.resetPassword(
      token: token,
      newPassword: newPassword,
    );

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Password reset failed.',
        code: response.error?.code ?? 'RESET_PASSWORD_FAILED',
      );
    }

    return response.data?['message']?.toString() ??
        'Your password has been reset successfully. Please sign in with your new credentials.';
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to update password.',
        code: response.error?.code ?? 'CHANGE_PASSWORD_FAILED',
      );
    }

    return response.data?['message']?.toString() ??
        'Password updated successfully';
  }

  @override
  Future<String> verifyEmail({required String token}) async {
    final response = await _apiService.verifyEmail(token: token);

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Email verification failed.',
        code: response.error?.code ?? 'VERIFY_EMAIL_FAILED',
      );
    }

    return response.data?['message']?.toString() ??
        'Email address verified successfully';
  }

  @override
  Future<String> resendVerificationEmail({
    required String email,
    String? tenantCode,
  }) async {
    final response = await _apiService.resendVerificationEmail(
      email: email,
      tenantCode: tenantCode,
    );

    if (!response.success) {
      throw BadResponseException(
        message:
            response.error?.message ?? 'Failed to resend verification email.',
        code: response.error?.code ?? 'RESEND_VERIFICATION_FAILED',
      );
    }

    return response.data?['message']?.toString() ??
        'If the account exists and is unverified, a verification email has been dispatched.';
  }

  @override
  Future<OtpRequestResponse> requestOtp({
    required String identifier,
    required OtpPurpose purpose,
    String? tenantCode,
  }) async {
    final response = await _apiService.requestOtp(
      identifier: identifier,
      purpose: purpose,
      tenantCode: tenantCode,
    );

    if (!response.success || response.data == null) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to request OTP.',
        code: response.error?.code ?? 'OTP_REQUEST_FAILED',
      );
    }

    return response.data!;
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String identifier,
    required OtpPurpose purpose,
    required String code,
  }) async {
    final response = await _apiService.verifyOtp(
      identifier: identifier,
      purpose: purpose,
      code: code,
    );

    if (!response.success || response.data == null) {
      throw BadResponseException(
        message: response.error?.message ?? 'Invalid OTP code.',
        code: response.error?.code ?? 'OTP_VERIFICATION_FAILED',
      );
    }

    return response.data!;
  }

  @override
  Future<AuthenticatedUser> getCurrentUser() async {
    final response = await _apiService.getMe();

    if (!response.success || response.data == null) {
      throw UnauthorizedException(
        message: response.error?.message ?? 'User not authenticated.',
        code: response.error?.code ?? 'GET_ME_FAILED',
      );
    }

    final rawUser = response.data?['user'];
    if (rawUser is! Map<String, dynamic>) {
      throw const ParseException(message: 'Invalid user payload received.');
    }

    return AuthenticatedUser.fromJson(rawUser);
  }

  @override
  Future<List<AuthSessionItem>> getSessions() async {
    final response = await _apiService.getSessions();

    if (!response.success || response.data == null) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to retrieve sessions.',
        code: response.error?.code ?? 'GET_SESSIONS_FAILED',
      );
    }

    return response.data!;
  }

  @override
  Future<String> revokeSession(String sessionId) async {
    final response = await _apiService.revokeSession(sessionId);

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to revoke session.',
        code: response.error?.code ?? 'REVOKE_SESSION_FAILED',
      );
    }

    return response.data?['message']?.toString() ??
        'Session successfully revoked';
  }

  @override
  Future<int> revokeAllSessions({bool preserveCurrentSession = true}) async {
    final response = await _apiService.revokeAllSessions(
      preserveCurrentSession: preserveCurrentSession,
    );

    if (!response.success) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to revoke sessions.',
        code: response.error?.code ?? 'REVOKE_ALL_SESSIONS_FAILED',
      );
    }

    return (response.data?['revokedCount'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<List<LoginHistoryItem>> getLoginHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiService.getLoginHistory(
      limit: limit,
      offset: offset,
    );

    if (!response.success || response.data == null) {
      throw BadResponseException(
        message: response.error?.message ?? 'Failed to retrieve login history.',
        code: response.error?.code ?? 'GET_LOGIN_HISTORY_FAILED',
      );
    }

    return response.data!;
  }

  @override
  Future<bool> hasStoredTokens() async {
    return _tokenStorage.hasTokens();
  }

  @override
  Future<void> clearLocalAuth() async {
    await _tokenStorage.clearTokens();
  }
}
