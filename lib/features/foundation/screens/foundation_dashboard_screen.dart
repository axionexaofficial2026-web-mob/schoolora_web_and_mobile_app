import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/env_config.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../providers/config_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/meta_provider.dart';

class FoundationDashboardScreen extends StatefulWidget {
  const FoundationDashboardScreen({super.key});

  @override
  State<FoundationDashboardScreen> createState() =>
      _FoundationDashboardScreenState();
}

class _FoundationDashboardScreenState extends State<FoundationDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    context.read<HealthProvider>().fetchHealth();
    context.read<MetaProvider>().fetchMeta();
    context.read<ConfigProvider>().fetchPublicConfig();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return SingleChildScrollView(
      padding: AppSpacing.insetAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Phase 1 Foundation Dashboard',
            subtitle:
                'Axionexa Schoolaora ERP — Core State, Dio API, and Design System Monitor',
            breadcrumbs: const [
              BreadcrumbItem(label: 'Home'),
              BreadcrumbItem(label: 'Foundation Dashboard'),
            ],
            actions: [
              Consumer<HealthProvider>(
                builder: (context, healthProv, _) {
                  return AppButton(
                    text: 'Refresh Endpoints',
                    icon: const Icon(Icons.refresh, size: 16),
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    isLoading: healthProv.isLoading || healthProv.isRefreshing,
                    onPressed: _refreshAllData,
                  );
                },
              ),
              AppButton(
                text: 'View System Details',
                icon: const Icon(Icons.terminal, size: 16),
                size: AppButtonSize.sm,
                onPressed: () => context.go(RoutePaths.systemStatus),
              ),
            ],
          ),

          // Environment & Architecture banner
          _buildArchitectureBanner(theme, isDark),
          const SizedBox(height: AppSpacing.xl),

          // 3 Metric Cards for Phase 1 Endpoints
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildHealthCard(context, theme, isDark)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildMetaCard(context, theme, isDark)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildConfigCard(context, theme, isDark)),
              ],
            )
          else
            Column(
              children: [
                _buildHealthCard(context, theme, isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildMetaCard(context, theme, isDark),
                const SizedBox(height: AppSpacing.lg),
                _buildConfigCard(context, theme, isDark),
              ],
            ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Navigation & Verification Card
          AppCard(
            title: 'Phase 1 Architecture Verification',
            subtitle:
                'Real-time pipeline: Flutter UI → Provider → Repository → ApiService → Dio → Backend API',
            headerAction: AppButton(
              text: 'UI Component Showcase',
              icon: const Icon(Icons.widgets_outlined, size: 16),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.sm,
              onPressed: () => context.go(RoutePaths.componentShowcase),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Implementation Highlights:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildChecklistRow(
                  'Provider State Management',
                  'Modular ChangeNotifiers (HealthProvider, MetaProvider, ConfigProvider, ThemeProvider) handle loading, success, error, and refresh states cleanly outside widgets.',
                  theme,
                  isDark,
                ),
                _buildChecklistRow(
                  'Dio Centralized Network Layer',
                  'Timeout configurations (15s), correlation ID headers (x-correlation-id), safe developer logging with token sanitization, and pre-wired auth interceptor hooks.',
                  theme,
                  isDark,
                ),
                _buildChecklistRow(
                  'Global Design System & Plus Jakarta Sans',
                  'Material 3 design tokens with tailored Light and Dark themes, typography weights (H1 700, H2 600, Body 400, Labels 500, Buttons 600).',
                  theme,
                  isDark,
                ),
                _buildChecklistRow(
                  'Responsive SaaS Web Foundation',
                  'Adaptive desktop sidebar with topbar, tablet navigation rail, and mobile drawer/bottom navigation with high contrast and touch accessibility.',
                  theme,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureBanner(ThemeData theme, bool isDark) {
    return Container(
      padding: AppSpacing.insetAllLg,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryDarkTheme.withValues(alpha: 0.1)
            : AppColors.primaryTint.withValues(alpha: 0.6),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? AppColors.primaryDarkTheme.withValues(alpha: 0.3)
              : AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryDarkTheme
                  : AppColors.primaryLight,
              borderRadius: AppRadius.borderMd,
            ),
            child: const Icon(
              Icons.hub_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected to API Gateway: ${EnvConfig.apiBaseUrl}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Environment: ${EnvConfig.currentEnvironment.name.toUpperCase()}  •  API Version: ${EnvConfig.apiVersion}  •  Multi-tenancy Phase 1 Ready',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<HealthProvider>(
      builder: (context, prov, _) {
        Widget content;
        if (prov.isLoading && prov.health == null) {
          content = const AppLoading(message: 'Querying /api/v1/health...');
        } else if (prov.isError) {
          content = AppErrorState(
            title: 'Health Check Failed',
            message:
                prov.error?.message ??
                'Could not reach backend health endpoint.',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchHealth(),
          );
        } else if (prov.health != null) {
          final health = prov.health!;
          final isOperational = health.isHealthy;
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Status:', style: theme.textTheme.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOperational
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      health.status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isOperational
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Uptime:', style: theme.textTheme.bodyMedium),
                  Text(
                    '${health.uptimeSeconds} seconds',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Database:', style: theme.textTheme.bodyMedium),
                  Text(
                    health.services['database']?.status.toUpperCase() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: health.services['database']?.isConnected == true
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Redis Cache:', style: theme.textTheme.bodyMedium),
                  Text(
                    health.services['redis']?.status.toUpperCase() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: health.services['redis']?.isConnected == true
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          content = const Text('No health data available.');
        }

        return AppCard(
          title: 'System Health',
          subtitle: 'GET /api/v1/health',
          child: content,
        );
      },
    );
  }

  Widget _buildMetaCard(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<MetaProvider>(
      builder: (context, prov, _) {
        Widget content;
        if (prov.isLoading && prov.meta == null) {
          content = const AppLoading(message: 'Querying /api/v1/meta...');
        } else if (prov.isError) {
          content = AppErrorState(
            title: 'Meta Fetch Failed',
            message:
                prov.error?.message ?? 'Could not reach backend meta endpoint.',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchMeta(),
          );
        } else if (prov.meta != null) {
          final meta = prov.meta!;
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Application:', style: theme.textTheme.bodyMedium),
                  Text(
                    meta.appName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Version / Phase:', style: theme.textTheme.bodyMedium),
                  Text(
                    'v${meta.version} (${meta.phase})',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Multi-Tenancy:', style: theme.textTheme.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      meta.multiTenancy?.supported == true
                          ? 'SUPPORTED'
                          : 'DISABLED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Phase 1 APIs:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${meta.supportedModulesPhase1.length} Endpoints',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          );
        } else {
          content = const Text('No meta data available.');
        }

        return AppCard(
          title: 'System Metadata',
          subtitle: 'GET /api/v1/meta',
          child: content,
        );
      },
    );
  }

  Widget _buildConfigCard(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<ConfigProvider>(
      builder: (context, prov, _) {
        Widget content;
        if (prov.isLoading && prov.config == null) {
          content = const AppLoading(
            message: 'Querying /api/v1/config/public...',
          );
        } else if (prov.isError) {
          content = AppErrorState(
            title: 'Config Fetch Failed',
            message:
                prov.error?.message ??
                'Could not reach backend public config endpoint.',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchPublicConfig(),
          );
        } else if (prov.config != null) {
          final cfg = prov.config!;
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Brand / Locale:', style: theme.textTheme.bodyMedium),
                  Text(
                    '${cfg.branding.defaultLocale} (${cfg.branding.defaultTimezone})',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upload Limit:', style: theme.textTheme.bodyMedium),
                  Text(
                    '${cfg.uploads.maxUploadSizeMb} MB',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Maintenance Mode:', style: theme.textTheme.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.system.maintenanceMode
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.success.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      cfg.system.maintenanceMode ? 'ACTIVE' : 'OFFLINE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cfg.system.maintenanceMode
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MIME Types Allowed:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${cfg.uploads.allowedMimeTypes.length} Types',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          );
        } else {
          content = const Text('No public config available.');
        }

        return AppCard(
          title: 'Public Configuration',
          subtitle: 'GET /api/v1/config/public',
          child: content,
        );
      },
    );
  }

  Widget _buildChecklistRow(
    String title,
    String desc,
    ThemeData theme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: desc,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
