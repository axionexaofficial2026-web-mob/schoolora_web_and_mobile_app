import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/app_exception.dart';
import 'package:schoolora_web_and_mobile_app/data/models/config_model.dart';
import 'package:schoolora_web_and_mobile_app/data/models/health_model.dart';
import 'package:schoolora_web_and_mobile_app/data/models/meta_model.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/config_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/health_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/meta_repository.dart';
import 'package:schoolora_web_and_mobile_app/providers/config_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/health_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/meta_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/theme_provider.dart';
import 'package:schoolora_web_and_mobile_app/providers/view_state.dart';

class MockHealthRepository extends Mock implements IHealthRepository {}

class MockMetaRepository extends Mock implements IMetaRepository {}

class MockConfigRepository extends Mock implements IConfigRepository {}

void main() {
  group('ThemeProvider Tests', () {
    test('Initial theme mode is light', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('Toggle theme switches between light and dark', () {
      final provider = ThemeProvider();
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);

      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('Explicitly set theme mode', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });
  });

  group('HealthProvider Tests', () {
    late MockHealthRepository mockRepo;
    late HealthProvider provider;

    setUp(() {
      mockRepo = MockHealthRepository();
      provider = HealthProvider(mockRepo);
    });

    test('Initial state is ViewState.initial', () {
      expect(provider.state, ViewState.initial);
      expect(provider.health, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, false);
    });

    test('fetchHealth success transitions from loading to success', () async {
      const fakeHealth = HealthModel(
        status: 'healthy',
        uptimeSeconds: 3600,
        environment: 'development',
        version: '1.0.0',
      );

      when(() => mockRepo.getHealth()).thenAnswer((_) async => fakeHealth);

      final future = provider.fetchHealth();
      expect(provider.isLoading, true);

      await future;

      expect(provider.state, ViewState.success);
      expect(provider.health, isNotNull);
      expect(provider.health?.status, 'healthy');
      expect(provider.health?.uptimeSeconds, 3600);
      expect(provider.error, isNull);
      expect(provider.lastCheckedAt, isNotNull);
    });

    test('fetchHealth failure transitions to error state', () async {
      when(
        () => mockRepo.getHealth(),
      ).thenThrow(const NetworkException(message: 'Connection refused'));

      await provider.fetchHealth();

      expect(provider.state, ViewState.error);
      expect(provider.health, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, isA<NetworkException>());
    });

    test(
      'silentRefresh sets refreshing state when data already exists',
      () async {
        const fakeHealth = HealthModel(status: 'healthy', uptimeSeconds: 100);
        when(() => mockRepo.getHealth()).thenAnswer((_) async => fakeHealth);

        await provider.fetchHealth();
        expect(provider.state, ViewState.success);

        final future = provider.fetchHealth(silentRefresh: true);
        expect(provider.isRefreshing, true);
        await future;
        expect(provider.state, ViewState.success);
      },
    );
  });

  group('MetaProvider Tests', () {
    late MockMetaRepository mockRepo;
    late MetaProvider provider;

    setUp(() {
      mockRepo = MockMetaRepository();
      provider = MetaProvider(mockRepo);
    });

    test('Initial state is ViewState.initial', () {
      expect(provider.state, ViewState.initial);
      expect(provider.meta, isNull);
    });

    test('fetchMeta success transitions to success state', () async {
      const fakeMeta = MetaModel(
        appName: 'Schoolaora ERP',
        version: '1.0.0',
        phase: 'Phase 1',
        environment: 'development',
        apiVersion: 'v1',
      );

      when(() => mockRepo.getMeta()).thenAnswer((_) async => fakeMeta);

      await provider.fetchMeta();

      expect(provider.state, ViewState.success);
      expect(provider.meta?.appName, 'Schoolaora ERP');
      expect(provider.error, isNull);
    });

    test('fetchMeta failure transitions to error state', () async {
      when(
        () => mockRepo.getMeta(),
      ).thenThrow(const ServerException(message: 'Server error'));

      await provider.fetchMeta();

      expect(provider.state, ViewState.error);
      expect(provider.error, isNotNull);
      expect(provider.meta, isNull);
    });
  });

  group('ConfigProvider Tests', () {
    late MockConfigRepository mockRepo;
    late ConfigProvider provider;

    setUp(() {
      mockRepo = MockConfigRepository();
      provider = ConfigProvider(mockRepo);
    });

    test('Initial state is ViewState.initial', () {
      expect(provider.state, ViewState.initial);
      expect(provider.config, isNull);
    });

    test('fetchPublicConfig success transitions to success state', () async {
      const fakeConfig = PublicConfigModel(
        branding: BrandingConfig(
          appName: 'Schoolaora ERP',
          defaultLocale: 'en-US',
          supportedLocales: ['en-US'],
          defaultTimezone: 'Asia/Kolkata',
        ),
        uploads: UploadsConfig(
          maxUploadSizeMb: 25,
          allowedMimeTypes: ['image/jpeg'],
        ),
        system: SystemConfig(maintenanceMode: false, apiVersion: 'v1'),
      );

      when(
        () => mockRepo.getPublicConfig(),
      ).thenAnswer((_) async => fakeConfig);

      await provider.fetchPublicConfig();

      expect(provider.state, ViewState.success);
      expect(provider.config?.branding.appName, 'Schoolaora ERP');
      expect(provider.config?.system.maintenanceMode, false);
      expect(provider.error, isNull);
    });

    test('fetchPublicConfig failure transitions to error state', () async {
      when(
        () => mockRepo.getPublicConfig(),
      ).thenThrow(const TimeoutException(message: 'Timeout error'));

      await provider.fetchPublicConfig();

      expect(provider.state, ViewState.error);
      expect(provider.error, isA<TimeoutException>());
      expect(provider.config, isNull);
    });
  });
}
