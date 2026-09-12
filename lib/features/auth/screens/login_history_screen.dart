import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/models/auth_models.dart';
import '../../../providers/auth_provider.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchLoginHistory();
    });
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
                title: 'Login Audit History',
                subtitle:
                    'Audit log of recent authentication attempts into your Schoolora account',
                breadcrumbs: const [
                  BreadcrumbItem(label: 'Home'),
                  BreadcrumbItem(label: 'Security'),
                  BreadcrumbItem(label: 'Login History'),
                ],
                actions: [
                  AppButton(
                    text: 'Refresh',
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: () => authProvider.fetchLoginHistory(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              if (authProvider.isLoading &&
                  authProvider.loginHistory.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: AppLoading(message: 'Loading login history...'),
                ),
              ] else if (authProvider.isError &&
                  authProvider.loginHistory.isEmpty) ...[
                AppErrorState(
                  title: 'Unable to load login history',
                  message:
                      authProvider.error?.message ??
                      'An error occurred retrieving authentication logs.',
                  onRetry: () => authProvider.fetchLoginHistory(),
                ),
              ] else if (authProvider.loginHistory.isEmpty) ...[
                const AppEmptyState(
                  title: 'No Login History Found',
                  message:
                      'There are no recorded login attempts for this user.',
                  icon: Icons.history_rounded,
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: authProvider.loginHistory.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = authProvider.loginHistory[index];
                    final isSuccess = item.status == LoginStatus.success;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? (isDark
                                        ? const Color(0xFF14532D)
                                        : const Color(0xFFDCFCE7))
                                  : (isDark
                                        ? const Color(0xFF7F1D1D)
                                        : const Color(0xFFFEE2E2)),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Icon(
                              isSuccess
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                              color: isSuccess
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isSuccess
                                          ? 'Successful Sign In'
                                          : 'Failed Sign In Attempt',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSuccess
                                                ? (isDark
                                                      ? AppColors.textDark
                                                      : AppColors.textLight)
                                                : AppColors.error,
                                          ),
                                    ),
                                    const Spacer(),
                                    if (item.createdAt != null)
                                      Text(
                                        DateFormat(
                                          'MMM d, y • HH:mm:ss',
                                        ).format(item.createdAt!),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: 2,
                                  children: [
                                    if (item.deviceInfo != null)
                                      Text(
                                        'Device: ${item.deviceInfo}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                    if (item.ipAddress != null)
                                      Text(
                                        'IP: ${item.ipAddress}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                      ),
                                    if (!isSuccess &&
                                        item.failureReason != null)
                                      Text(
                                        'Reason: ${item.failureReason}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
