import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;
  final String? tooltip;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dimensions based on size
    final double height;
    final EdgeInsets padding;
    final double fontSize;

    switch (size) {
      case AppButtonSize.sm:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md);
        fontSize = 12.0;
        break;
      case AppButtonSize.lg:
        height = 48.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
        fontSize = 15.0;
        break;
      case AppButtonSize.md:
        height = 42.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
        fontSize = 14.0;
        break;
    }

    // Colors based on variant
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDark
            ? AppColors.primaryDarkTheme
            : AppColors.primaryLight;
        foregroundColor = isDark ? AppColors.backgroundDark : Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark
            ? AppColors.primaryDarkTheme
            : AppColors.primaryLight;
        borderSide = BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        );
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.textDark : AppColors.textLight;
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    final bool isDisabled = onPressed == null || isLoading;
    if (isDisabled &&
        variant != AppButtonVariant.outline &&
        variant != AppButtonVariant.ghost) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: AppTypography.buttonTextStyle(
            foregroundColor,
          ).copyWith(fontSize: fontSize),
        ),
      ],
    );

    Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: borderSide ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: padding,
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: text,
      child: button,
    );
  }
}
