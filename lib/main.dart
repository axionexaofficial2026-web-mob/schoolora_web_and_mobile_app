import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/security/secure_token_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/config_repository.dart';
import 'data/repositories/health_repository.dart';
import 'data/repositories/meta_repository.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/config_api_service.dart';
import 'data/services/health_api_service.dart';
import 'data/services/meta_api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/config_provider.dart';
import 'providers/health_provider.dart';
import 'providers/meta_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Secure Token Storage
  final tokenStorage = SecureTokenStorage();

  AuthProvider? authProviderRef;

  // Initialize Core API Network Layer with token storage & 401 refresh hooks
  final dioClient = DioClient(
    baseUrl: EnvConfig.apiBaseUrl,
    tokenStorage: tokenStorage,
    onSessionExpired: () => authProviderRef?.handleSessionExpired(),
  );

  // Initialize API Services
  final authApiService = AuthApiService(dioClient);
  final healthApiService = HealthApiService(dioClient);
  final metaApiService = MetaApiService(dioClient);
  final configApiService = ConfigApiService(dioClient);

  // Initialize Repositories
  final authRepository = AuthRepository(authApiService, tokenStorage);
  final healthRepository = HealthRepository(healthApiService);
  final metaRepository = MetaRepository(metaApiService);
  final configRepository = ConfigRepository(configApiService);

  // Initialize AuthProvider and check existing stored tokens
  final authProvider = AuthProvider(authRepository)..initialize();
  authProviderRef = authProvider;

  // Create reactive GoRouter
  final router = AppRouter.createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialThemeMode: ThemeMode.light),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<HealthProvider>(
          create: (_) => HealthProvider(healthRepository),
        ),
        ChangeNotifierProvider<MetaProvider>(
          create: (_) => MetaProvider(metaRepository),
        ),
        ChangeNotifierProvider<ConfigProvider>(
          create: (_) => ConfigProvider(configRepository),
        ),
      ],
      child: SchooloraErpApp(router: router),
    ),
  );
}

class SchooloraErpApp extends StatelessWidget {
  final GoRouter router;

  const SchooloraErpApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: EnvConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
