import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:schoolora_web_and_mobile_app/core/theme/app_theme.dart';
import 'package:schoolora_web_and_mobile_app/data/models/auth_models.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/auth_repository.dart';
import 'package:schoolora_web_and_mobile_app/features/auth/screens/sessions_screen.dart';
import 'package:schoolora_web_and_mobile_app/providers/auth_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/theme_provider.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('SessionsScreen Widget Tests', () {
    late MockAuthRepository mockRepo;
    late AuthProvider authProvider;
    late ThemeProvider themeProvider;

    setUp(() {
      mockRepo = MockAuthRepository();
      authProvider = AuthProvider(mockRepo);
      themeProvider = ThemeProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SessionsScreen(),
        ),
      );
    }

    testWidgets('Renders sessions list with current session indicator', (
      tester,
    ) async {
      final sessions = [
        AuthSessionItem(
          id: 'sess-current',
          deviceInfo: 'MacBook Pro / Chrome',
          ipAddress: '192.168.1.10',
          isCurrent: true,
          createdAt: DateTime(2026, 9, 12, 10, 0),
        ),
        AuthSessionItem(
          id: 'sess-mobile',
          deviceInfo: 'iPhone 15 / Safari',
          ipAddress: '10.0.0.5',
          isCurrent: false,
          createdAt: DateTime(2026, 9, 11, 8, 30),
        ),
      ];

      when(() => mockRepo.getSessions()).thenAnswer((_) async => sessions);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active Sessions & Devices'), findsOneWidget);
      expect(find.text('MacBook Pro / Chrome'), findsOneWidget);
      expect(find.text('Current Session'), findsOneWidget);
      expect(find.text('iPhone 15 / Safari'), findsOneWidget);
      expect(find.text('Revoke'), findsOneWidget);
    });
  });
}
