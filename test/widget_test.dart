import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:schoolora_web_and_mobile_app/core/theme/app_theme.dart';
import 'package:schoolora_web_and_mobile_app/features/foundation/screens/foundation_dashboard_screen.dart';
import 'package:schoolora_web_and_mobile_app/providers/config_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/health_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/meta_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/theme_provider.dart';
import 'unit/providers_test.dart';

void main() {
  testWidgets('App root smoke test and provider wiring', (
    WidgetTester tester,
  ) async {
    final mockHealthRepo = MockHealthRepository();
    final mockMetaRepo = MockMetaRepository();
    final mockConfigRepo = MockConfigRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<HealthProvider>(
            create: (_) => HealthProvider(mockHealthRepo),
          ),
          ChangeNotifierProvider<MetaProvider>(
            create: (_) => MetaProvider(mockMetaRepo),
          ),
          ChangeNotifierProvider<ConfigProvider>(
            create: (_) => ConfigProvider(mockConfigRepo),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const FoundationDashboardScreen(),
        ),
      ),
    );

    // Verify header and dashboard elements are present
    expect(find.text('Phase 1 Foundation Dashboard'), findsOneWidget);
    expect(
      find.text(
        'Axionexa Schoolaora ERP — Core State, Dio API, and Design System Monitor',
      ),
      findsOneWidget,
    );
    expect(find.text('Refresh Endpoints'), findsOneWidget);
  });
}
