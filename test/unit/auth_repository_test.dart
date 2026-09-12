import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/app_exception.dart';
import 'package:schoolora_web_and_mobile_app/core/security/secure_token_storage.dart';
import 'package:schoolora_web_and_mobile_app/data/models/api_response.dart';
import 'package:schoolora_web_and_mobile_app/data/models/auth_models.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/auth_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/services/auth_api_service.dart';

class MockAuthApiService extends Mock implements AuthApiService {}

void main() {
  group('AuthRepository Tests', () {
    late MockAuthApiService mockApiService;
    late InMemoryTokenStorage tokenStorage;
    late AuthRepository repository;

    setUp(() {
      mockApiService = MockAuthApiService();
      tokenStorage = InMemoryTokenStorage();
      repository = AuthRepository(mockApiService, tokenStorage);
    });

    final testUser = AuthenticatedUser(
      id: 'usr-1',
      tenantId: 'ten-1',
      email: 'teacher@schoolora.com',
      firstName: 'Jane',
      lastName: 'Doe',
      status: UserStatus.active,
      emailVerified: true,
      mustChangePassword: false,
    );

    final testTokens = const AuthTokens(
      accessToken: 'test_access_jwt',
      refreshToken: 'test_refresh_jwt',
    );

    test(
      'login success saves tokens to secure storage and returns data',
      () async {
        when(
          () => mockApiService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            tenantCode: any(named: 'tenantCode'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse<LoginResponseData>(
            success: true,
            data: LoginResponseData(
              user: testUser,
              tokens: testTokens,
              mustChangePassword: false,
            ),
          ),
        );

        final result = await repository.login(
          email: 'teacher@schoolora.com',
          password: 'Password123!',
        );

        expect(result.user.id, 'usr-1');
        expect(result.tokens.accessToken, 'test_access_jwt');
        expect(await tokenStorage.getAccessToken(), 'test_access_jwt');
        expect(await tokenStorage.getRefreshToken(), 'test_refresh_jwt');
        expect(await tokenStorage.hasTokens(), true);
      },
    );

    test(
      'login failure throws BadResponseException and does not store tokens',
      () async {
        when(
          () => mockApiService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            tenantCode: any(named: 'tenantCode'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse<LoginResponseData>(
            success: false,
            error: ApiErrorPayload(
              code: 'INVALID_CREDENTIALS',
              message: 'Invalid email or password provided',
            ),
          ),
        );

        expect(
          () =>
              repository.login(email: 'wrong@schoolora.com', password: 'wrong'),
          throwsA(isA<BadResponseException>()),
        );
        expect(await tokenStorage.hasTokens(), false);
      },
    );

    test('logout clears secure tokens even if server logout fails', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_acc',
        refreshToken: 'old_ref',
      );

      when(
        () => mockApiService.logout(refreshToken: any(named: 'refreshToken')),
      ).thenThrow(const ServerException(message: 'Network offline'));

      await repository.logout();

      expect(await tokenStorage.hasTokens(), false);
      expect(await tokenStorage.getAccessToken(), isNull);
    });

    test('refresh rotates tokens in storage on success', () async {
      await tokenStorage.saveTokens(
        accessToken: 'initial_acc',
        refreshToken: 'initial_ref',
      );

      const rotatedTokens = AuthTokens(
        accessToken: 'rotated_acc',
        refreshToken: 'rotated_ref',
      );

      when(
        () => mockApiService.refresh(refreshToken: 'initial_ref'),
      ).thenAnswer(
        (_) async =>
            const ApiResponse<AuthTokens>(success: true, data: rotatedTokens),
      );

      final result = await repository.refresh();

      expect(result.accessToken, 'rotated_acc');
      expect(await tokenStorage.getAccessToken(), 'rotated_acc');
      expect(await tokenStorage.getRefreshToken(), 'rotated_ref');
    });

    test(
      'refresh throws UnauthorizedException when no refresh token stored',
      () async {
        expect(
          () => repository.refresh(),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );

    test('forgotPassword returns success message', () async {
      when(
        () => mockApiService.forgotPassword(
          email: any(named: 'email'),
          tenantCode: any(named: 'tenantCode'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {'message': 'Reset email sent'},
        ),
      );

      final msg = await repository.forgotPassword(email: 'test@schoolora.com');
      expect(msg, 'Reset email sent');
    });

    test('resetPassword returns success confirmation', () async {
      when(
        () => mockApiService.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {'message': 'Password reset successful'},
        ),
      );

      final msg = await repository.resetPassword(
        token: 'valid_token_123',
        newPassword: 'NewPassword123!',
      );
      expect(msg, 'Password reset successful');
    });

    test('changePassword updates password', () async {
      when(
        () => mockApiService.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {'message': 'Password updated successfully'},
        ),
      );

      final msg = await repository.changePassword(
        currentPassword: 'OldPass123!',
        newPassword: 'NewPass456!',
      );
      expect(msg, 'Password updated successfully');
    });

    test('getCurrentUser retrieves authenticated user profile', () async {
      when(() => mockApiService.getMe()).thenAnswer(
        (_) async => ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'user': testUser.toJson(),
            'session': {'id': 's-1'},
          },
        ),
      );

      final user = await repository.getCurrentUser();
      expect(user.id, 'usr-1');
      expect(user.fullName, 'Jane Doe');
    });

    test('getSessions returns session list', () async {
      const session = AuthSessionItem(
        id: 'sess-1',
        deviceInfo: 'MacBook Pro',
        ipAddress: '192.168.1.5',
        isCurrent: true,
      );

      when(() => mockApiService.getSessions()).thenAnswer(
        (_) async => const ApiResponse<List<AuthSessionItem>>(
          success: true,
          data: [session],
        ),
      );

      final sessions = await repository.getSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'sess-1');
      expect(sessions.first.activeIsCurrent, true);
    });

    test('revokeSession revokes specific session', () async {
      when(() => mockApiService.revokeSession(any())).thenAnswer(
        (_) async => const ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {'message': 'Session revoked'},
        ),
      );

      final msg = await repository.revokeSession('sess-2');
      expect(msg, 'Session revoked');
    });

    test('revokeAllSessions revokes other sessions', () async {
      when(
        () => mockApiService.revokeAllSessions(
          preserveCurrentSession: any(named: 'preserveCurrentSession'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {'message': 'Revoked', 'revokedCount': 3},
        ),
      );

      final count = await repository.revokeAllSessions();
      expect(count, 3);
    });

    test('getLoginHistory returns audit events', () async {
      const historyItem = LoginHistoryItem(
        id: 'h-1',
        status: LoginStatus.success,
        ipAddress: '10.0.0.1',
      );

      when(
        () => mockApiService.getLoginHistory(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<List<LoginHistoryItem>>(
          success: true,
          data: [historyItem],
        ),
      );

      final history = await repository.getLoginHistory();
      expect(history.length, 1);
      expect(history.first.isSuccess, true);
    });
  });
}
