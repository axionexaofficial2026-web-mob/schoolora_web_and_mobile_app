import '../../core/config/app_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class AuthApiService extends BaseApiService {
  AuthApiService(super.dioClient);

  Future<ApiResponse<LoginResponseData>> login({
    required String email,
    required String password,
    String? tenantCode,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      if (tenantCode != null && tenantCode.isNotEmpty)
        'tenantCode': tenantCode.trim().toLowerCase(),
    };

    return postEnvelope<LoginResponseData>(
      path: AppConstants.endpointLogin,
      data: payload,
      fromJsonT: (raw) =>
          LoginResponseData.fromJson(raw as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> logout({
    String? refreshToken,
  }) async {
    final payload = <String, dynamic>{
      if (refreshToken != null && refreshToken.isNotEmpty)
        'refreshToken': refreshToken,
    };

    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointLogout,
      data: payload,
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<AuthTokens>> refresh({
    required String refreshToken,
  }) async {
    return postEnvelope<AuthTokens>(
      path: AppConstants.endpointRefresh,
      data: {'refreshToken': refreshToken},
      fromJsonT: (raw) => AuthTokens.fromJson(raw as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
    String? tenantCode,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      if (tenantCode != null && tenantCode.isNotEmpty)
        'tenantCode': tenantCode.trim().toLowerCase(),
    };

    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointForgotPassword,
      data: payload,
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointResetPassword,
      data: {'token': token, 'newPassword': newPassword},
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointChangePassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointVerifyEmail,
      data: {'token': token},
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resendVerificationEmail({
    required String email,
    String? tenantCode,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      if (tenantCode != null && tenantCode.isNotEmpty)
        'tenantCode': tenantCode.trim().toLowerCase(),
    };

    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointResendVerificationEmail,
      data: payload,
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<OtpRequestResponse>> requestOtp({
    required String identifier,
    required OtpPurpose purpose,
    String? tenantCode,
  }) async {
    final payload = <String, dynamic>{
      'identifier': identifier.trim(),
      'purpose': purpose.toBackendString(),
      if (tenantCode != null && tenantCode.isNotEmpty)
        'tenantCode': tenantCode.trim().toLowerCase(),
    };

    return postEnvelope<OtpRequestResponse>(
      path: AppConstants.endpointOtpRequest,
      data: payload,
      fromJsonT: (raw) =>
          OtpRequestResponse.fromJson(raw as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<OtpVerifyResponse>> verifyOtp({
    required String identifier,
    required OtpPurpose purpose,
    required String code,
  }) async {
    return postEnvelope<OtpVerifyResponse>(
      path: AppConstants.endpointOtpVerify,
      data: {
        'identifier': identifier.trim(),
        'purpose': purpose.toBackendString(),
        'code': code.trim(),
      },
      fromJsonT: (raw) =>
          OtpVerifyResponse.fromJson(raw as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    return getEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointMe,
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<List<AuthSessionItem>>> getSessions() async {
    return getEnvelope<List<AuthSessionItem>>(
      path: AppConstants.endpointSessions,
      fromJsonT: (raw) {
        if (raw is List) {
          return raw
              .map(
                (item) =>
                    AuthSessionItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <AuthSessionItem>[];
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> revokeSession(
    String sessionId,
  ) async {
    return deleteEnvelope<Map<String, dynamic>>(
      path: '${AppConstants.endpointSessions}/$sessionId',
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> revokeAllSessions({
    bool preserveCurrentSession = true,
  }) async {
    return postEnvelope<Map<String, dynamic>>(
      path: AppConstants.endpointSessionsRevokeAll,
      data: {'preserveCurrentSession': preserveCurrentSession},
      fromJsonT: (raw) =>
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
    );
  }

  Future<ApiResponse<List<LoginHistoryItem>>> getLoginHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    return getEnvelope<List<LoginHistoryItem>>(
      path: AppConstants.endpointLoginHistory,
      queryParameters: {'limit': limit, 'offset': offset},
      fromJsonT: (raw) {
        if (raw is List) {
          return raw
              .map(
                (item) =>
                    LoginHistoryItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <LoginHistoryItem>[];
      },
    );
  }
}
