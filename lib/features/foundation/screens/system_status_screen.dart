import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../providers/config_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/meta_provider.dart';

class SystemStatusScreen extends StatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  State<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends State<SystemStatusScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.insetAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Backend System Inspector',
            subtitle:
                'Real-time telemetry and API response inspection for Phase 1 endpoints',
            breadcrumbs: const [
              BreadcrumbItem(label: 'Home'),
              BreadcrumbItem(label: 'System Status'),
            ],
            actions: [
              AppButton(
                text: 'Refresh All',
                icon: const Icon(Icons.sync, size: 16),
                size: AppButtonSize.sm,
                variant: AppButtonVariant.primary,
                onPressed: () {
                  context.read<HealthProvider>().fetchHealth();
                  context.read<MetaProvider>().fetchMeta();
                  context.read<ConfigProvider>().fetchPublicConfig();
                },
              ),
            ],
          ),

          // Tab navigation
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: isDark
                  ? AppColors.primaryDarkTheme
                  : AppColors.primaryLight,
              labelColor: isDark
                  ? AppColors.primaryDarkTheme
                  : AppColors.primaryLight,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.favorite_outline, size: 18),
                  text: 'Health (/health)',
                ),
                Tab(
                  icon: Icon(Icons.info_outline, size: 18),
                  text: 'Meta (/meta)',
                ),
                Tab(
                  icon: Icon(Icons.settings_outlined, size: 18),
                  text: 'Config (/config/public)',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 620,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHealthTab(context, theme, isDark),
                _buildMetaTab(context, theme, isDark),
                _buildConfigTab(context, theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<HealthProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.health == null) {
          return const AppLoading(message: 'Retrieving /api/v1/health...');
        }
        if (prov.isError) {
          return AppErrorState(
            title: 'Health Query Failed',
            message: prov.error?.message ?? 'Unknown health error',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchHealth(),
          );
        }
        if (prov.health == null) {
          return const Center(child: Text('No health data loaded.'));
        }

        final h = prov.health!;
        return SingleChildScrollView(
          child: Column(
            children: [
              AppCard(
                title: 'Operational Status Overview',
                subtitle: 'Timestamp: ${h.timestamp ?? "N/A"}',
                headerAction: AppButton(
                  text: 'Refresh',
                  icon: const Icon(Icons.refresh, size: 14),
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.ghost,
                  isLoading: prov.isRefreshing,
                  onPressed: () => prov.fetchHealth(silentRefresh: true),
                ),
                child: Column(
                  children: [
                    _buildDataRow(
                      'Overall System Status',
                      h.status.toUpperCase(),
                      isDark,
                      highlight: true,
                    ),
                    _buildDataRow(
                      'Process Uptime',
                      '${h.uptimeSeconds} seconds',
                      isDark,
                    ),
                    _buildDataRow(
                      'Environment',
                      h.environment ?? 'development',
                      isDark,
                    ),
                    _buildDataRow(
                      'Backend Version',
                      h.version ?? '1.0.0',
                      isDark,
                    ),
                    _buildDataRow(
                      'Node.js Version',
                      h.system?.nodeVersion ?? 'N/A',
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                title: 'Subsystem Checks',
                subtitle: 'Database & Cache connectivity and health status',
                child: Column(
                  children: [
                    ...h.services.entries.map((entry) {
                      final serviceName = entry.key.toUpperCase();
                      final item = entry.value;
                      return _buildDataRow(
                        '$serviceName Service',
                        '${item.status.toUpperCase()}${item.latencyMs != null ? " (${item.latencyMs}ms)" : ""}',
                        isDark,
                        badgeColor: item.isConnected
                            ? AppColors.success
                            : AppColors.warning,
                      );
                    }),
                    if (h.system?.memoryUsageMb != null) ...[
                      const Divider(height: AppSpacing.xl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Memory Usage Breakdown (MB):',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDataRow(
                        'RSS',
                        '${h.system!.memoryUsageMb!.rss} MB',
                        isDark,
                      ),
                      _buildDataRow(
                        'Heap Total',
                        '${h.system!.memoryUsageMb!.heapTotal} MB',
                        isDark,
                      ),
                      _buildDataRow(
                        'Heap Used',
                        '${h.system!.memoryUsageMb!.heapUsed} MB',
                        isDark,
                      ),
                      _buildDataRow(
                        'External',
                        '${h.system!.memoryUsageMb!.externalUsage} MB',
                        isDark,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaTab(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<MetaProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.meta == null) {
          return const AppLoading(message: 'Retrieving /api/v1/meta...');
        }
        if (prov.isError) {
          return AppErrorState(
            title: 'Meta Query Failed',
            message: prov.error?.message ?? 'Unknown meta error',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchMeta(),
          );
        }
        if (prov.meta == null) {
          return const Center(child: Text('No metadata loaded.'));
        }

        final m = prov.meta!;
        return SingleChildScrollView(
          child: AppCard(
            title: 'Application Metadata & Multi-Tenancy Architecture',
            subtitle: 'GET /api/v1/meta contract verification',
            headerAction: AppButton(
              text: 'Refresh',
              icon: const Icon(Icons.refresh, size: 14),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.ghost,
              isLoading: prov.isRefreshing,
              onPressed: () => prov.fetchMeta(silentRefresh: true),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Application Name', m.appName, isDark),
                _buildDataRow('Version', m.version, isDark),
                _buildDataRow('Current Phase', m.phase, isDark),
                _buildDataRow('Environment', m.environment, isDark),
                _buildDataRow('API Version', m.apiVersion, isDark),
                _buildDataRow(
                  'Multi-Tenancy Supported',
                  m.multiTenancy?.supported == true ? 'YES' : 'NO',
                  isDark,
                  badgeColor: m.multiTenancy?.supported == true
                      ? AppColors.success
                      : AppColors.error,
                ),
                if (m.multiTenancy?.isolationLevel != null)
                  _buildDataRow(
                    'Isolation Strategy',
                    m.multiTenancy!.isolationLevel!,
                    isDark,
                  ),
                const Divider(height: AppSpacing.xl),
                Text(
                  'Supported Phase 1 Modules:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...m.supportedModulesPhase1.map((mod) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          mod,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigTab(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<ConfigProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.config == null) {
          return const AppLoading(
            message: 'Retrieving /api/v1/config/public...',
          );
        }
        if (prov.isError) {
          return AppErrorState(
            title: 'Public Config Query Failed',
            message: prov.error?.message ?? 'Unknown config error',
            errorCode: prov.error?.code,
            onRetry: () => prov.fetchPublicConfig(),
          );
        }
        if (prov.config == null) {
          return const Center(child: Text('No public configuration loaded.'));
        }

        final c = prov.config!;
        return SingleChildScrollView(
          child: AppCard(
            title: 'Public Configuration Payload',
            subtitle: 'GET /api/v1/config/public contract verification',
            headerAction: AppButton(
              text: 'Refresh',
              icon: const Icon(Icons.refresh, size: 14),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.ghost,
              isLoading: prov.isRefreshing,
              onPressed: () => prov.fetchPublicConfig(silentRefresh: true),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Brand App Name', c.branding.appName, isDark),
                _buildDataRow(
                  'Default Locale',
                  c.branding.defaultLocale,
                  isDark,
                ),
                _buildDataRow(
                  'Default Timezone',
                  c.branding.defaultTimezone,
                  isDark,
                ),
                _buildDataRow(
                  'Supported Locales',
                  c.branding.supportedLocales.join(', '),
                  isDark,
                ),
                const Divider(height: AppSpacing.xl),
                _buildDataRow(
                  'Max Upload Size',
                  '${c.uploads.maxUploadSizeMb} MB',
                  isDark,
                ),
                _buildDataRow(
                  'Maintenance Mode',
                  c.system.maintenanceMode ? 'ENABLED' : 'DISABLED',
                  isDark,
                  badgeColor: c.system.maintenanceMode
                      ? AppColors.warning
                      : AppColors.success,
                ),
                _buildDataRow(
                  'System API Version',
                  c.system.apiVersion,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Allowed Upload MIME Types (${c.uploads.allowedMimeTypes.length}):',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: c.uploads.allowedMimeTypes.map((mime) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : const Color(0xFFF1F5F9),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        mime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(
    String label,
    String value,
    bool isDark, {
    bool highlight = false,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight
                    ? (isDark
                          ? AppColors.primaryDarkTheme
                          : AppColors.primaryLight)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
