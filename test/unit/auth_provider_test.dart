import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/app_exception.dart';
import 'package:schoolora_web_and_mobile_app/data/models/auth_models.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/auth_repository.dart';
import 'package:schoolora_web_and_mobile_app/providers/auth_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/view_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('AuthProvider Tests', () {
    late MockAuthRepository mockRepo;
    late AuthProvider provider;

    final testUser = AuthenticatedUser(
      id: 'usr-42',
      tenantId: 'ten-school',
      email: 'teacher@schoolora.com',
      firstName: 'Alice',
      lastName: 'Wonderland',
      status: UserStatus.active,
      emailVerified: true,
      mustChangePassword: false,
    );

    final loginData = LoginResponseData(
      user: testUser,
      tokens: const AuthTokens(
        accessToken: 'access_jwt',
        refreshToken: 'refresh_jwt',
      ),
      mustChangePassword: false,
    );

    setUp(() {
      mockRepo = MockAuthRepository();
      provider = AuthProvider(mockRepo);
    });

    test('Initial state is correct', () {
      expect(provider.state, ViewState.initial);
      expect(provider.isAuthenticated, false);
      expect(provider.currentUser, isNull);
      expect(provider.mustChangePassword, false);
      expect(provider.sessionExpired, false);
    });

    test('initialize with no stored tokens sets unauthenticated', () async {
      when(() => mockRepo.hasStoredTokens()).thenAnswer((_) async => false);

      await provider.initialize();

      expect(provider.isAuthenticated, false);
      expect(provider.currentUser, isNull);
    });

    test(
      'initialize with valid tokens restores authenticated session',
      () async {
        when(() => mockRepo.hasStoredTokens()).thenAnswer((_) async => true);
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);

        await provider.initialize();

        expect(provider.isAuthenticated, true);
        expect(provider.currentUser?.id, 'usr-42');
        expect(provider.currentUser?.firstName, 'Alice');
        expect(provider.state, ViewState.success);
      },
    );

    test(
      'initialize resets auth if getCurrentUser throws unauthorized',
      () async {
        when(() => mockRepo.hasStoredTokens()).thenAnswer((_) async => true);
        when(
          () => mockRepo.getCurrentUser(),
        ).thenThrow(const UnauthorizedException(message: 'Token expired'));
        when(() => mockRepo.clearLocalAuth()).thenAnswer((_) async {});

        await provider.initialize();

        expect(provider.isAuthenticated, false);
        expect(provider.currentUser, isNull);
        verify(() => mockRepo.clearLocalAuth()).called(1);
      },
    );

    test(
      'login success sets authenticated user and notifies listeners',
      () async {
        when(
          () => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            tenantCode: any(named: 'tenantCode'),
          ),
        ).thenAnswer((_) async => loginData);

        final success = await provider.login(
          email: 'teacher@schoolora.com',
          password: 'Password123!',
        );

        expect(success, true);
        expect(provider.isAuthenticated, true);
        expect(provider.currentUser?.id, 'usr-42');
        expect(provider.state, ViewState.success);
        expect(provider.error, isNull);
      },
    );

    test('login with mustChangePassword flag propagates to provider', () async {
      final mustChangeData = LoginResponseData(
        user: testUser,
        tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
        mustChangePassword: true,
      );

      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          tenantCode: any(named: 'tenantCode'),
        ),
      ).thenAnswer((_) async => mustChangeData);

      final success = await provider.login(
        email: 'teacher@schoolora.com',
        password: 'TemporaryPassword123!',
      );

      expect(success, true);
      expect(provider.isAuthenticated, true);
      expect(provider.mustChangePassword, true);
    });

    test('login failure sets error state', () async {
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          tenantCode: any(named: 'tenantCode'),
        ),
      ).thenThrow(const BadResponseException(message: 'Invalid credentials'));

      final success = await provider.login(
        email: 'wrong@schoolora.com',
        password: 'wrong',
      );

      expect(success, false);
      expect(provider.isAuthenticated, false);
      expect(provider.state, ViewState.error);
      expect(provider.error?.message, 'Invalid credentials');
    });

    test('logout clears auth state completely', () async {
      when(() => mockRepo.logout()).thenAnswer((_) async {});

      await provider.logout();

      expect(provider.isAuthenticated, false);
      expect(provider.currentUser, isNull);
      expect(provider.mustChangePassword, false);
      expect(provider.state, ViewState.initial);
    });

    test('firstLoginChangePassword clears mustChangePassword flag', () async {
      when(
        () => mockRepo.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => 'Password updated');

      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);

      final success = await provider.firstLoginChangePassword(
        currentPassword: 'TempPassword123!',
        newPassword: 'NewSecurePassword123!',
      );

      expect(success, true);
      expect(provider.mustChangePassword, false);
      expect(provider.state, ViewState.success);
    });

    test(
      'handleSessionExpired sets sessionExpired flag and clears credentials',
      () {
        provider.handleSessionExpired();

        expect(provider.isAuthenticated, false);
        expect(provider.currentUser, isNull);
        expect(provider.sessionExpired, true);
        expect(provider.error?.code, 'SESSION_EXPIRED');

        provider.clearSessionExpiredFlag();
        expect(provider.sessionExpired, false);
      },
    );

    test('fetchSessions populates active session list', () async {
      const session = AuthSessionItem(
        id: 'sess-1',
        deviceInfo: 'Safari iOS',
        isCurrent: true,
      );

      when(() => mockRepo.getSessions()).thenAnswer((_) async => [session]);

      await provider.fetchSessions();

      expect(provider.sessions.length, 1);
      expect(provider.sessions.first.id, 'sess-1');
      expect(provider.state, ViewState.success);
    });

    test('fetchLoginHistory populates login history items', () async {
      const hist = LoginHistoryItem(id: 'hist-1', status: LoginStatus.success);

      when(
        () => mockRepo.getLoginHistory(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [hist]);

      await provider.fetchLoginHistory();

      expect(provider.loginHistory.length, 1);
      expect(provider.loginHistory.first.isSuccess, true);
    });
  });
}
