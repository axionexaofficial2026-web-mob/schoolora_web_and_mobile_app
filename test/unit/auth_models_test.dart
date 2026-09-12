import 'package:flutter_test/flutter_test.dart';
import 'package:schoolora_web_and_mobile_app/data/models/auth_models.dart';

void main() {
  group('Auth Models Tests', () {
    test('AuthenticatedUser parses from valid backend JSON', () {
      final json = {
        'id': 'usr-12345',
        'tenantId': 'ten-school-01',
        'schoolId': 'sch-primary-01',
        'branchId': 'br-main',
        'email': 'teacher@schoolora.com',
        'firstName': 'Sarah',
        'lastName': 'Connor',
        'phone': '+1234567890',
        'status': 'ACTIVE',
        'emailVerified': true,
        'mustChangePassword': false,
        'lastLoginAt': '2026-09-12T10:00:00.000Z',
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      final user = AuthenticatedUser.fromJson(json);

      expect(user.id, 'usr-12345');
      expect(user.tenantId, 'ten-school-01');
      expect(user.schoolId, 'sch-primary-01');
      expect(user.branchId, 'br-main');
      expect(user.email, 'teacher@schoolora.com');
      expect(user.firstName, 'Sarah');
      expect(user.lastName, 'Connor');
      expect(user.fullName, 'Sarah Connor');
      expect(user.phone, '+1234567890');
      expect(user.status, UserStatus.active);
      expect(user.emailVerified, true);
      expect(user.mustChangePassword, false);
      expect(user.lastLoginAt, isNotNull);
      expect(user.createdAt, isNotNull);

      final exportedJson = user.toJson();
      expect(exportedJson['id'], 'usr-12345');
      expect(exportedJson['status'], 'ACTIVE');
    });

    test('AuthenticatedUser handles nullable and fallback fields safely', () {
      final json = {
        'id': 'usr-999',
        'tenantId': 'ten-01',
        'email': 'guest@schoolora.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'status': 'UNKNOWN_VALUE',
        'emailVerified': false,
        'mustChangePassword': true,
      };

      final user = AuthenticatedUser.fromJson(json);

      expect(user.id, 'usr-999');
      expect(user.schoolId, isNull);
      expect(user.branchId, isNull);
      expect(user.phone, isNull);
      expect(user.status, UserStatus.pendingVerification);
      expect(user.emailVerified, false);
      expect(user.mustChangePassword, true);
      expect(user.lastLoginAt, isNull);
    });

    test('AuthTokens parses and serializes correctly', () {
      final json = {
        'accessToken': 'header.payload.signature',
        'refreshToken': 'rt_secret_token_123',
        'tokenType': 'Bearer',
        'expiresIn': '15m',
      };

      final tokens = AuthTokens.fromJson(json);

      expect(tokens.accessToken, 'header.payload.signature');
      expect(tokens.refreshToken, 'rt_secret_token_123');
      expect(tokens.tokenType, 'Bearer');
      expect(tokens.expiresIn, '15m');

      final exported = tokens.toJson();
      expect(exported['accessToken'], 'header.payload.signature');
      expect(exported['refreshToken'], 'rt_secret_token_123');
    });

    test('LoginResponseData deserializes full login response', () {
      final json = {
        'user': {
          'id': 'u-1',
          'tenantId': 't-1',
          'email': 'admin@schoolora.com',
          'firstName': 'Super',
          'lastName': 'Admin',
          'status': 'ACTIVE',
          'emailVerified': true,
          'mustChangePassword': true,
        },
        'tokens': {
          'accessToken': 'acc-tok',
          'refreshToken': 'ref-tok',
          'tokenType': 'Bearer',
          'expiresIn': '15m',
        },
        'session': {
          'id': 'sess-101',
          'deviceInfo': 'Chrome / macOS',
          'ipAddress': '192.168.1.1',
          'isCurrent': true,
          'isCurrentSession': true,
          'isRevoked': false,
        },
        'mustChangePassword': true,
      };

      final response = LoginResponseData.fromJson(json);

      expect(response.user.email, 'admin@schoolora.com');
      expect(response.tokens.accessToken, 'acc-tok');
      expect(response.tokens.refreshToken, 'ref-tok');
      expect(response.mustChangePassword, true);
      expect(response.session, isNotNull);
      expect(response.session!.id, 'sess-101');
      expect(response.session!.activeIsCurrent, true);
    });

    test('AuthSessionItem parses session status and dates', () {
      final json = {
        'id': 'sess-999',
        'deviceInfo': 'Mobile Safari / iOS 17',
        'ipAddress': '10.0.0.1',
        'isCurrent': false,
        'isCurrentSession': false,
        'isRevoked': false,
        'createdAt': '2026-09-12T12:00:00.000Z',
        'expiresAt': '2026-09-19T12:00:00.000Z',
      };

      final item = AuthSessionItem.fromJson(json);

      expect(item.id, 'sess-999');
      expect(item.deviceInfo, 'Mobile Safari / iOS 17');
      expect(item.ipAddress, '10.0.0.1');
      expect(item.activeIsCurrent, false);
      expect(item.isRevoked, false);
      expect(item.createdAt, isNotNull);
      expect(item.expiresAt, isNotNull);
    });

    test('LoginHistoryItem maps SUCCESS and FAILED audit entries', () {
      final successJson = {
        'id': 'hist-1',
        'status': 'SUCCESS',
        'ipAddress': '127.0.0.1',
        'deviceInfo': 'Windows 11 / Chrome',
        'createdAt': '2026-09-12T15:30:00.000Z',
      };

      final failedJson = {
        'id': 'hist-2',
        'status': 'FAILED',
        'failureReason': 'Invalid password credentials provided',
        'ipAddress': '127.0.0.1',
        'deviceInfo': 'Windows 11 / Chrome',
        'createdAt': '2026-09-12T15:29:00.000Z',
      };

      final successItem = LoginHistoryItem.fromJson(successJson);
      final failedItem = LoginHistoryItem.fromJson(failedJson);

      expect(successItem.isSuccess, true);
      expect(successItem.status, LoginStatus.success);
      expect(successItem.failureReason, isNull);

      expect(failedItem.isSuccess, false);
      expect(failedItem.status, LoginStatus.failed);
      expect(failedItem.failureReason, 'Invalid password credentials provided');
    });

    test('OtpRequestResponse and OtpVerifyResponse parse correctly', () {
      final reqJson = {
        'identifier': 'user@schoolora.com',
        'purpose': 'PASSWORD_RESET',
        'expiresInSeconds': 300,
        'message': 'OTP dispatched',
      };

      final verifyJson = {
        'verified': true,
        'message': 'OTP verification successful',
      };

      final req = OtpRequestResponse.fromJson(reqJson);
      final ver = OtpVerifyResponse.fromJson(verifyJson);

      expect(req.identifier, 'user@schoolora.com');
      expect(req.purpose, OtpPurpose.passwordReset);
      expect(req.expiresInSeconds, 300);
      expect(req.message, 'OTP dispatched');

      expect(ver.verified, true);
      expect(ver.message, 'OTP verification successful');
    });
  });
}
