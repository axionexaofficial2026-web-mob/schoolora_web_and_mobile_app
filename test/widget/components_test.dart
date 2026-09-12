import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolora_web_and_mobile_app/core/theme/app_theme.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_button.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_card.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_empty_state.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_error_state.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_loading.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_pagination.dart';
import 'package:schoolora_web_and_mobile_app/core/widgets/app_search_field.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('Renders button text and handles onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          AppButton(text: 'Save Changes', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Save Changes'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, true);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithTheme(const AppButton(text: 'Submitting', isLoading: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppCard Widget Tests', () {
    testWidgets('Renders title, subtitle, header action, and content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          AppCard(
            title: 'Card Title',
            subtitle: 'Card Subtitle',
            headerAction: const Icon(Icons.more_vert),
            child: const Text('Inner Content'),
          ),
        ),
      );

      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.text('Inner Content'), findsOneWidget);
    });
  });

  group('AppErrorState Widget Tests', () {
    testWidgets('Renders error details and triggers retry callback', (
      tester,
    ) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          AppErrorState(
            title: 'Failed to Connect',
            message: 'Server unreachable',
            errorCode: 'NET_001',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Failed to Connect'), findsOneWidget);
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Code: NET_001'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });
  });

  group('AppEmptyState Widget Tests', () {
    testWidgets('Renders empty title, message, and action button', (
      tester,
    ) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          AppEmptyState(
            title: 'No Items Found',
            message: 'Try changing your filter settings',
            actionText: 'Clear Filters',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('No Items Found'), findsOneWidget);
      expect(find.text('Try changing your filter settings'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);

      await tester.tap(find.text('Clear Filters'));
      expect(actionTriggered, true);
    });
  });

  group('AppLoading Widget Tests', () {
    testWidgets('Renders spinner and message', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(const AppLoading(message: 'Loading data...')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });
  });

  group('AppPagination Widget Tests', () {
    testWidgets('Calculates page counts and triggers page change', (
      tester,
    ) async {
      int newPage = 1;
      await tester.pumpWidget(
        _wrapWithTheme(
          AppPagination(
            currentPage: 1,
            totalItems: 30,
            pageSize: 10,
            onPageChanged: (page) => newPage = page,
          ),
        ),
      );

      expect(find.text('Showing 1-10 of 30'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(newPage, 2);
    });
  });

  group('AppSearchField Widget Tests', () {
    testWidgets('Accepts input and emits onSubmitted', (tester) async {
      String submitted = '';
      await tester.pumpWidget(
        _wrapWithTheme(
          AppSearchField(
            hintText: 'Search modules...',
            onSubmitted: (val) => submitted = val,
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Academics');
      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(submitted, 'Academics');
    });
  });
}
