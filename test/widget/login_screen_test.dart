import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:schoolora_web_and_mobile_app/core/theme/app_theme.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/auth_repository.dart';
import 'package:schoolora_web_and_mobile_app/features/auth/screens/login_screen.dart';
import 'package:schoolora_web_and_mobile_app/providers/auth_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/theme_provider.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('LoginScreen Widget Tests', () {
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
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('Renders all login UI elements properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('Shows validation errors on empty submission', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Sign In button without entering credentials
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on suffix icon tap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final toggleIcon = find.byIcon(Icons.visibility_outlined);
      expect(toggleIcon, findsOneWidget);

      await tester.tap(toggleIcon);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
      'Displays session expired warning banner when sessionExpired is true',
      (tester) async {
        authProvider.handleSessionExpired();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.text('Your session has expired. Please sign in again.'),
          findsOneWidget,
        );
      },
    );
  });
}
