import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolora_web_and_mobile_app/core/config/app_constants.dart';
import 'package:schoolora_web_and_mobile_app/core/network/interceptors/api_interceptor.dart';
import 'package:schoolora_web_and_mobile_app/core/security/secure_token_storage.dart';

class MockDio extends Mock implements Dio {}

class MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

class FakeResponse extends Fake implements Response<dynamic> {}

class FakeDioException extends Fake implements DioException {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeResponse());
    registerFallbackValue(FakeDioException());
  });

  group('ApiInterceptor Unit Tests', () {
    late InMemoryTokenStorage tokenStorage;
    late MockDio mockMainDio;
    late MockDio mockRefreshDio;
    bool sessionExpiredCalled = false;

    setUp(() {
      tokenStorage = InMemoryTokenStorage();
      mockMainDio = MockDio();
      mockRefreshDio = MockDio();
      sessionExpiredCalled = false;
    });

    test(
      'onRequest injects Bearer token from tokenStorage and correlation ID',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'secure_access_token_123',
          refreshToken: 'secure_refresh_token_456',
        );

        final interceptor = ApiInterceptor(tokenStorage: tokenStorage);

        final options = RequestOptions(path: '/api/v1/test');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(
          options.headers[AppConstants.headerAuthorization],
          'Bearer secure_access_token_123',
        );
        expect(
          options.headers.containsKey(AppConstants.headerCorrelationId),
          true,
        );
      },
    );

    test(
      'onError on 401 attempts automatic refresh and retries failed request',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'expired_access_token',
          refreshToken: 'valid_refresh_token',
        );

        final interceptor = ApiInterceptor(
          tokenStorage: tokenStorage,
          dio: mockMainDio,
          refreshDio: mockRefreshDio,
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
        );

        // Mock refresh endpoint response
        when(
          () => mockRefreshDio.post<Map<String, dynamic>>(
            AppConstants.endpointRefresh,
            data: {'refreshToken': 'valid_refresh_token'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: AppConstants.endpointRefresh),
            statusCode: 200,
            data: {
              'success': true,
              'data': {
                'accessToken': 'new_fresh_access_token',
                'refreshToken': 'new_fresh_refresh_token',
              },
            },
          ),
        );

        final reqOptions = RequestOptions(
          path: '/api/v1/data',
          method: 'GET',
          headers: {'Authorization': 'Bearer expired_access_token'},
        );

        final retryResponse = Response(
          requestOptions: reqOptions,
          statusCode: 200,
          data: {'result': 'success_after_refresh'},
        );

        // Mock retry request
        when(
          () => mockMainDio.request<dynamic>(
            '/api/v1/data',
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            options: any(named: 'options'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer((_) async => retryResponse);

        final dioError = DioException(
          requestOptions: reqOptions,
          response: Response(requestOptions: reqOptions, statusCode: 401),
        );

        final handler = MockErrorHandler();
        when(() => handler.resolve(any())).thenReturn(null);
        when(() => handler.next(any())).thenReturn(null);

        await interceptor.onError(dioError, handler);

        // Verify tokens were rotated
        expect(await tokenStorage.getAccessToken(), 'new_fresh_access_token');
        expect(await tokenStorage.getRefreshToken(), 'new_fresh_refresh_token');
        expect(sessionExpiredCalled, false);
        verify(() => handler.resolve(any())).called(1);
      },
    );

    test(
      'onError on refresh failure clears tokens and triggers onSessionExpired',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'invalid_refresh_token',
        );

        final interceptor = ApiInterceptor(
          tokenStorage: tokenStorage,
          dio: mockMainDio,
          refreshDio: mockRefreshDio,
          onSessionExpired: () {
            sessionExpiredCalled = true;
          },
        );

        // Mock refresh endpoint failure (e.g. 401)
        when(
          () => mockRefreshDio.post<Map<String, dynamic>>(
            AppConstants.endpointRefresh,
            data: {'refreshToken': 'invalid_refresh_token'},
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: AppConstants.endpointRefresh),
            response: Response(
              requestOptions: RequestOptions(
                path: AppConstants.endpointRefresh,
              ),
              statusCode: 401,
            ),
          ),
        );

        final reqOptions = RequestOptions(
          path: '/api/v1/protected',
          method: 'GET',
        );

        final dioError = DioException(
          requestOptions: reqOptions,
          response: Response(requestOptions: reqOptions, statusCode: 401),
        );

        final handler = MockErrorHandler();
        when(() => handler.next(any())).thenReturn(null);

        await interceptor.onError(dioError, handler);

        expect(sessionExpiredCalled, true);
        expect(await tokenStorage.hasTokens(), false);
        verify(() => handler.next(dioError)).called(1);
      },
    );

    test('onError does not loop if request was already retried', () async {
      final interceptor = ApiInterceptor(
        tokenStorage: tokenStorage,
        dio: mockMainDio,
        refreshDio: mockRefreshDio,
      );

      final reqOptions = RequestOptions(
        path: '/api/v1/resource',
        extra: {'isRetry': true},
      );

      final dioError = DioException(
        requestOptions: reqOptions,
        response: Response(requestOptions: reqOptions, statusCode: 401),
      );

      final handler = MockErrorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.onError(dioError, handler);

      // Ensure no refresh request was triggered
      verifyNever(() => mockRefreshDio.post<Map<String, dynamic>>(any()));
      verify(() => handler.next(dioError)).called(1);
    });
  });
}
