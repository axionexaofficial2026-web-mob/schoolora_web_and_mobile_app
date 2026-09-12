import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/models/auth_models.dart';
import '../../../providers/auth_provider.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchSessions();
    });
  }

  Future<void> _revokeSession(AuthSessionItem session) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Revoke Device Session',
      message:
          'Are you sure you want to sign out session on "${session.deviceInfo ?? 'Unknown Device'}"? The device will lose access immediately.',
      confirmText: 'Revoke Session',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().revokeSession(session.id);
    }
  }

  Future<void> _revokeAllSessions() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Revoke All Other Sessions',
      message:
          'Are you sure you want to revoke all active sessions except this current device? All other logged-in browsers and mobile devices will be signed out.',
      confirmText: 'Revoke All Others',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().revokeAllSessions(
        preserveCurrentSession: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetAllXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: 'Active Sessions & Devices',
                subtitle:
                    'Manage browsers and mobile apps currently signed into your Schoolora account',
                breadcrumbs: const [
                  BreadcrumbItem(label: 'Home'),
                  BreadcrumbItem(label: 'Security'),
                  BreadcrumbItem(label: 'Sessions'),
                ],
                actions: [
                  AppButton(
                    text: 'Revoke All Other Sessions',
                    variant: AppButtonVariant.danger,
                    size: AppButtonSize.sm,
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    onPressed: authProvider.sessions.length > 1
                        ? _revokeAllSessions
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    text: 'Refresh',
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: () => authProvider.fetchSessions(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              if (authProvider.isLoading && authProvider.sessions.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: AppLoading(message: 'Loading active sessions...'),
                ),
              ] else if (authProvider.isError &&
                  authProvider.sessions.isEmpty) ...[
                AppErrorState(
                  title: 'Unable to load sessions',
                  message:
                      authProvider.error?.message ??
                      'An error occurred loading device sessions.',
                  onRetry: () => authProvider.fetchSessions(),
                ),
              ] else if (authProvider.sessions.isEmpty) ...[
                const AppEmptyState(
                  title: 'No Active Sessions',
                  message:
                      'No other active device sessions found for this account.',
                  icon: Icons.devices_other_rounded,
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: authProvider.sessions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final session = authProvider.sessions[index];
                    final isCurrent = session.activeIsCurrent;

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: isCurrent
                              ? (isDark
                                    ? AppColors.primaryDarkTheme
                                    : AppColors.primaryLight)
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? (isDark
                                        ? const Color(0xFF1E3A8A)
                                        : const Color(0xFFDBEAFE))
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: Icon(
                              Icons.laptop_chromebook_rounded,
                              color: isCurrent
                                  ? AppColors.primaryLight
                                  : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        session.deviceInfo ??
                                            'Unknown Device / Browser',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF14532D)
                                              : const Color(0xFFDCFCE7),
                                          borderRadius: AppRadius.borderFull,
                                        ),
                                        child: Text(
                                          'Current Session',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: 4,
                                  children: [
                                    if (session.ipAddress != null)
                                      Text(
                                        'IP: ${session.ipAddress}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                    if (session.createdAt != null)
                                      Text(
                                        'Started: ${DateFormat('MMM d, y • HH:mm').format(session.createdAt!)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (!isCurrent) ...[
                            const SizedBox(width: AppSpacing.md),
                            AppButton(
                              text: 'Revoke',
                              variant: AppButtonVariant.outline,
                              size: AppButtonSize.sm,
                              onPressed: () => _revokeSession(session),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
