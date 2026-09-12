import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.padding = AppSpacing.insetAllLg,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBorderColor = borderColor ?? theme.dividerColor;
    final effectiveBgColor =
        backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || headerAction != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: (padding as EdgeInsets).left,
              right: (padding as EdgeInsets).right,
              top: (padding as EdgeInsets).top,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(title!, style: theme.textTheme.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                ?headerAction,
              ],
            ),
          ),
          Divider(height: 1, color: effectiveBorderColor),
          Padding(padding: padding, child: child),
        ] else
          Padding(padding: padding, child: child),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: effectiveBorderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderLg,
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: AppRadius.borderLg,
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
