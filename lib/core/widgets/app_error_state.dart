import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final Widget? customAction;

  const AppErrorState({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.errorCode,
    this.onRetry,
    this.retryButtonText = 'Retry',
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.insetAllXl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFFFEE2E2),
                  borderRadius: AppRadius.borderFull,
                ),
                child: const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (errorCode != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Code: $errorCode',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (customAction != null)
                customAction!
              else if (onRetry != null)
                AppButton(
                  text: retryButtonText,
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: onRetry,
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.md,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
