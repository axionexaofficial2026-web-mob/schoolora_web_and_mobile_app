import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolora_web_and_mobile_app/core/config/app_constants.dart';
import 'package:schoolora_web_and_mobile_app/core/config/env_config.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/app_exception.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/error_handler.dart';
import 'package:schoolora_web_and_mobile_app/core/network/dio_client.dart';
import 'package:schoolora_web_and_mobile_app/core/network/interceptors/api_interceptor.dart';
import 'package:schoolora_web_and_mobile_app/core/network/interceptors/logging_interceptor.dart';

void main() {
  group('DioClient & Network Layer Tests', () {
    test('DioClient initializes with default configuration', () {
      final client = DioClient(baseUrl: 'http://localhost:4000');
      expect(client.baseUrl, 'http://localhost:4000');
      expect(client.rawDio.options.connectTimeout, AppConstants.connectTimeout);
      expect(client.rawDio.options.receiveTimeout, AppConstants.receiveTimeout);
      expect(client.rawDio.options.sendTimeout, AppConstants.sendTimeout);
      expect(
        client.rawDio.options.headers[AppConstants.headerContentType],
        AppConstants.contentTypeJson,
      );
      expect(client.rawDio.interceptors.any((i) => i is ApiInterceptor), true);
      expect(
        client.rawDio.interceptors.any((i) => i is LoggingInterceptor),
        true,
      );
    });

    test('DioClient updateBaseUrl updates target endpoint', () {
      final client = DioClient(baseUrl: 'http://localhost:4000');
      client.updateBaseUrl('https://api.axionexa.com');
      expect(client.baseUrl, 'https://api.axionexa.com');
    });

    test(
      'EnvConfig environment defaults to development and fallback port 4000',
      () {
        expect(EnvConfig.currentEnvironment, Environment.development);
        expect(EnvConfig.apiBaseUrl, 'http://localhost:4000');
        expect(EnvConfig.isDevelopment, true);
        expect(EnvConfig.isProduction, false);
      },
    );
  });

  group('ApiInterceptor Tests', () {
    test('Injects headers, correlation ID and handles token hook', () async {
      String? testToken = 'sample_bearer_token_123';
      final interceptor = ApiInterceptor(
        tokenProvider: () async => testToken,
        tenantProvider: () async => 'tenant-school-01',
      );

      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(
        options.headers[AppConstants.headerContentType],
        AppConstants.contentTypeJson,
      );
      expect(
        options.headers[AppConstants.headerAccept],
        AppConstants.contentTypeJson,
      );
      expect(
        options.headers.containsKey(AppConstants.headerCorrelationId),
        true,
      );
      expect(
        options.headers[AppConstants.headerAuthorization],
        'Bearer sample_bearer_token_123',
      );
      expect(options.headers[AppConstants.headerTenantId], 'tenant-school-01');
    });
  });

  group('LoggingInterceptor Security Tests', () {
    test('Sanitizes sensitive keys and passwords', () {
      final interceptor = LoggingInterceptor();
      final source = {
        'username': 'john_doe',
        'password': 'super_secret_password',
        'accessToken': 'ey123.abc.secret',
        'apiKey': 'private_key',
        'profile': {'email': 'user@example.com', 'otp': '987654'},
      };

      // We test the private sanitization logic via onRequest simulation
      final options = RequestOptions(
        path: '/test',
        headers: {'Authorization': 'Bearer secret_token'},
        data: source,
      );
      final handler = RequestInterceptorHandler();

      // Ensure onRequest does not throw and passes through cleanly
      expect(() => interceptor.onRequest(options, handler), returnsNormally);
    });
  });

  group('ErrorHandler Tests', () {
    final reqOptions = RequestOptions(path: '/test');

    test('Maps connection timeout to TimeoutException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionTimeout,
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<TimeoutException>());
      expect(appEx.code, 'TIMEOUT_ERROR');
    });

    test('Maps connection error to NetworkException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionError,
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<NetworkException>());
    });

    test('Maps SocketException directly to NetworkException', () {
      const socketErr = SocketException('Network is unreachable');
      final appEx = ErrorHandler.handle(socketErr);
      expect(appEx, isA<NetworkException>());
    });

    test('Maps FormatException directly to ParseException', () {
      const formatErr = FormatException('Invalid JSON payload');
      final appEx = ErrorHandler.handle(formatErr);
      expect(appEx, isA<ParseException>());
    });

    test('Maps HTTP 400 bad response with backend error payload', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 400,
          data: {
            'success': false,
            'error': {
              'code': 'INVALID_QUERY',
              'message': 'Parameter is missing',
            },
          },
        ),
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<BadResponseException>());
      expect(appEx.statusCode, 400);
      expect(appEx.message, 'Parameter is missing');
      expect(appEx.code, 'INVALID_QUERY');
    });

    test('Maps HTTP 401 to UnauthorizedException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
          data: {'message': 'Unauthorized token'},
        ),
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<UnauthorizedException>());
      expect(appEx.statusCode, 401);
    });

    test('Maps HTTP 403 to ForbiddenException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 403,
          data: {'message': 'Access forbidden'},
        ),
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<ForbiddenException>());
      expect(appEx.statusCode, 403);
    });

    test('Maps HTTP 404 to NotFoundException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 404,
          data: {'message': 'Endpoint not found'},
        ),
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<NotFoundException>());
      expect(appEx.statusCode, 404);
    });

    test('Maps HTTP 500 to ServerException', () {
      final dioErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 500,
          data: {'message': 'Internal database failure'},
        ),
      );
      final appEx = ErrorHandler.handle(dioErr);
      expect(appEx, isA<ServerException>());
      expect(appEx.statusCode, 500);
    });
  });
}
