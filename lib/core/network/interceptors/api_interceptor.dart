import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_constants.dart';
import '../../security/secure_token_storage.dart';

typedef TokenProvider = Future<String?> Function();
typedef TenantProvider = Future<String?> Function();

/// Centralized API Interceptor for:
/// 1. Correlation tracing IDs
/// 2. Authorization header injection
/// 3. Automatic 401 token refresh with concurrency deduplication
/// 4. Session expiration callback triggering
class ApiInterceptor extends Interceptor {
  final ISecureTokenStorage? tokenStorage;
  final TokenProvider? tokenProvider;
  final TenantProvider? tenantProvider;
  final VoidCallback? onSessionExpired;
  final Dio? dio;
  final Dio? refreshDio;

  static const String _kIsRetryKey = 'isRetry';

  // Concurrency lock for token refresh
  Future<String?>? _ongoingRefreshFuture;

  ApiInterceptor({
    this.tokenStorage,
    this.tokenProvider,
    this.tenantProvider,
    this.onSessionExpired,
    this.dio,
    this.refreshDio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Standard Content-Type and Accept headers
    options.headers[AppConstants.headerContentType] =
        AppConstants.contentTypeJson;
    options.headers[AppConstants.headerAccept] = AppConstants.contentTypeJson;

    // Attach correlation ID for end-to-end tracing if absent
    if (!options.headers.containsKey(AppConstants.headerCorrelationId)) {
      options.headers[AppConstants.headerCorrelationId] =
          _generateCorrelationId();
    }

    // Attach Bearer Access Token
    String? token;
    if (tokenStorage != null) {
      token = await tokenStorage!.getAccessToken();
    } else if (tokenProvider != null) {
      token = await tokenProvider!();
    }

    if (token != null && token.isNotEmpty) {
      options.headers[AppConstants.headerAuthorization] = 'Bearer $token';
    }

    // Attach Tenant ID if configured
    if (tenantProvider != null) {
      final tenantId = await tenantProvider!();
      if (tenantId != null && tenantId.isNotEmpty) {
        options.headers[AppConstants.headerTenantId] = tenantId;
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isRetry = err.requestOptions.extra[_kIsRetryKey] == true;
    final isAuthEndpoint =
        path.contains(AppConstants.endpointLogin) ||
        path.contains(AppConstants.endpointRefresh) ||
        path.contains('/auth/refresh-token');

    // If not a 401, or already retried, or an auth login/refresh endpoint itself:
    if (!is401 || isRetry || isAuthEndpoint) {
      if (is401 && path.contains(AppConstants.endpointRefresh)) {
        await _handleSessionExpired();
      }
      return handler.next(err);
    }

    // If we have token storage and a dio instance, attempt automatic token refresh
    if (tokenStorage == null || dio == null) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _executeOrWaitRefresh();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _handleSessionExpired();
        return handler.next(err);
      }

      // Clone original request and retry with newly acquired token
      final originalOptions = err.requestOptions;
      final retryOptions = Options(
        method: originalOptions.method,
        headers: Map<String, dynamic>.from(originalOptions.headers)
          ..[AppConstants.headerAuthorization] = 'Bearer $newAccessToken',
        responseType: originalOptions.responseType,
        contentType: originalOptions.contentType,
        validateStatus: originalOptions.validateStatus,
        receiveTimeout: originalOptions.receiveTimeout,
        sendTimeout: originalOptions.sendTimeout,
        extra: Map<String, dynamic>.from(originalOptions.extra)
          ..[_kIsRetryKey] = true,
      );

      final retryResponse = await dio!.request<dynamic>(
        originalOptions.path,
        data: originalOptions.data,
        queryParameters: originalOptions.queryParameters,
        cancelToken: originalOptions.cancelToken,
        options: retryOptions,
        onReceiveProgress: originalOptions.onReceiveProgress,
        onSendProgress: originalOptions.onSendProgress,
      );

      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(err);
    }
  }

  Future<String?> _executeOrWaitRefresh() async {
    if (_ongoingRefreshFuture != null) {
      return _ongoingRefreshFuture;
    }

    final completer = Completer<String?>();
    _ongoingRefreshFuture = completer.future;

    try {
      final refreshToken = await tokenStorage!.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      // Use a dedicated refresh Dio instance to avoid interceptor recursion
      final client =
          refreshDio ??
          Dio(
            BaseOptions(
              baseUrl: dio?.options.baseUrl ?? '',
              connectTimeout: AppConstants.connectTimeout,
              receiveTimeout: AppConstants.receiveTimeout,
              headers: {
                AppConstants.headerContentType: AppConstants.contentTypeJson,
                AppConstants.headerAccept: AppConstants.contentTypeJson,
              },
            ),
          );

      final response = await client.post<Map<String, dynamic>>(
        AppConstants.endpointRefresh,
        data: {'refreshToken': refreshToken},
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        final data = responseData['data'];
        String? newAccess;
        String? newRefresh;

        if (data is Map<String, dynamic>) {
          newAccess = data['accessToken']?.toString();
          newRefresh = data['refreshToken']?.toString();
        }

        if (newAccess != null && newAccess.isNotEmpty) {
          await tokenStorage!.saveTokens(
            accessToken: newAccess,
            refreshToken: (newRefresh != null && newRefresh.isNotEmpty)
                ? newRefresh
                : refreshToken,
          );
          completer.complete(newAccess);
          return newAccess;
        }
      }

      completer.complete(null);
      return null;
    } catch (e) {
      completer.complete(null);
      return null;
    } finally {
      _ongoingRefreshFuture = null;
    }
  }

  Future<void> _handleSessionExpired() async {
    try {
      await tokenStorage?.clearTokens();
    } catch (_) {}
    onSessionExpired?.call();
  }

  String _generateCorrelationId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randHex = random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'req-$timestamp-$randHex';
  }
}
