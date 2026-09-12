import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolora_web_and_mobile_app/core/errors/app_exception.dart';
import 'package:schoolora_web_and_mobile_app/data/models/api_response.dart';
import 'package:schoolora_web_and_mobile_app/data/models/config_model.dart';
import 'package:schoolora_web_and_mobile_app/data/models/health_model.dart';
import 'package:schoolora_web_and_mobile_app/data/models/meta_model.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/config_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/health_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/repositories/meta_repository.dart';
import 'package:schoolora_web_and_mobile_app/data/services/config_api_service.dart';
import 'package:schoolora_web_and_mobile_app/data/services/health_api_service.dart';
import 'package:schoolora_web_and_mobile_app/data/services/meta_api_service.dart';

class MockHealthApiService extends Mock implements HealthApiService {}

class MockMetaApiService extends Mock implements MetaApiService {}

class MockConfigApiService extends Mock implements ConfigApiService {}

void main() {
  group('HealthRepository Tests', () {
    late MockHealthApiService mockService;
    late HealthRepository repository;

    setUp(() {
      mockService = MockHealthApiService();
      repository = HealthRepository(mockService);
    });

    test('getHealth returns HealthModel when API call succeeds', () async {
      const mockHealth = HealthModel(status: 'healthy', uptimeSeconds: 200);
      const mockResponse = ApiResponse<HealthModel>(
        success: true,
        data: mockHealth,
      );

      when(() => mockService.getHealth()).thenAnswer((_) async => mockResponse);

      final result = await repository.getHealth();
      expect(result.status, 'healthy');
      expect(result.uptimeSeconds, 200);
    });

    test(
      'getHealth throws ServerException when API responds with success: false',
      () async {
        const mockResponse = ApiResponse<HealthModel>(
          success: false,
          error: ApiErrorPayload(
            code: 'UNHEALTHY',
            message: 'Database is down',
          ),
        );

        when(
          () => mockService.getHealth(),
        ).thenAnswer((_) async => mockResponse);

        expect(() => repository.getHealth(), throwsA(isA<ServerException>()));
      },
    );
  });

  group('MetaRepository Tests', () {
    late MockMetaApiService mockService;
    late MetaRepository repository;

    setUp(() {
      mockService = MockMetaApiService();
      repository = MetaRepository(mockService);
    });

    test('getMeta returns MetaModel when API call succeeds', () async {
      const mockMeta = MetaModel(
        appName: 'Schoolaora ERP',
        version: '1.0.0',
        phase: 'Phase 1',
        environment: 'development',
        apiVersion: 'v1',
      );
      const mockResponse = ApiResponse<MetaModel>(
        success: true,
        data: mockMeta,
      );

      when(() => mockService.getMeta()).thenAnswer((_) async => mockResponse);

      final result = await repository.getMeta();
      expect(result.appName, 'Schoolaora ERP');
      expect(result.version, '1.0.0');
    });

    test(
      'getMeta throws ServerException when API responds with success: false',
      () async {
        const mockResponse = ApiResponse<MetaModel>(
          success: false,
          error: ApiErrorPayload(
            code: 'FETCH_ERROR',
            message: 'Cannot read meta',
          ),
        );

        when(() => mockService.getMeta()).thenAnswer((_) async => mockResponse);

        expect(() => repository.getMeta(), throwsA(isA<ServerException>()));
      },
    );
  });

  group('ConfigRepository Tests', () {
    late MockConfigApiService mockService;
    late ConfigRepository repository;

    setUp(() {
      mockService = MockConfigApiService();
      repository = ConfigRepository(mockService);
    });

    test(
      'getPublicConfig returns PublicConfigModel when API call succeeds',
      () async {
        const mockConfig = PublicConfigModel(
          branding: BrandingConfig(
            appName: 'Schoolaora ERP',
            defaultLocale: 'en-US',
            supportedLocales: ['en-US'],
            defaultTimezone: 'Asia/Kolkata',
          ),
          uploads: UploadsConfig(maxUploadSizeMb: 25, allowedMimeTypes: []),
          system: SystemConfig(maintenanceMode: false, apiVersion: 'v1'),
        );
        const mockResponse = ApiResponse<PublicConfigModel>(
          success: true,
          data: mockConfig,
        );

        when(
          () => mockService.getPublicConfig(),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.getPublicConfig();
        expect(result.branding.appName, 'Schoolaora ERP');
        expect(result.uploads.maxUploadSizeMb, 25);
      },
    );

    test(
      'getPublicConfig throws ServerException when API responds with success: false',
      () async {
        const mockResponse = ApiResponse<PublicConfigModel>(
          success: false,
          error: ApiErrorPayload(
            code: 'CONFIG_ERR',
            message: 'Config unavailable',
          ),
        );

        when(
          () => mockService.getPublicConfig(),
        ).thenAnswer((_) async => mockResponse);

        expect(
          () => repository.getPublicConfig(),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
