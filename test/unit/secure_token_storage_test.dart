import 'package:flutter_test/flutter_test.dart';
import 'package:schoolora_web_and_mobile_app/core/security/secure_token_storage.dart';

void main() {
  group('SecureTokenStorage Tests', () {
    late InMemoryTokenStorage storage;

    setUp(() {
      storage = InMemoryTokenStorage();
    });

    test('Initial storage has no tokens', () async {
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.hasTokens(), false);
    });

    test(
      'saveTokens persists both access and refresh tokens securely',
      () async {
        await storage.saveTokens(
          accessToken: 'sample_access_jwt_123',
          refreshToken: 'sample_refresh_jwt_456',
        );

        expect(await storage.getAccessToken(), 'sample_access_jwt_123');
        expect(await storage.getRefreshToken(), 'sample_refresh_jwt_456');
        expect(await storage.hasTokens(), true);
      },
    );

    test('clearTokens completely wipes all stored tokens', () async {
      await storage.saveTokens(
        accessToken: 'sample_access_jwt_123',
        refreshToken: 'sample_refresh_jwt_456',
      );
      expect(await storage.hasTokens(), true);

      await storage.clearTokens();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.hasTokens(), false);
    });
  });
}
