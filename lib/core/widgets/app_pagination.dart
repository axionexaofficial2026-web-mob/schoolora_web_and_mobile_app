import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_utils.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int> pageSizeOptions;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    this.pageSize = AppConstants.defaultPageSize,
    required this.onPageChanged,
    this.onPageSizeChanged,
    this.pageSizeOptions = AppConstants.pageSizeOptions,
  });

  int get totalPages => (totalItems / pageSize).ceil().clamp(1, 999999);
  bool get hasPrevious => currentPage > 1;
  bool get hasNext => currentPage < totalPages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveUtils.isMobile(context);

    final startItem = totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endItem = (currentPage * pageSize).clamp(0, totalItems);

    final itemRangeText = 'Showing $startItem-$endItem of $totalItems';

    return Padding(
      padding: AppSpacing.insetVerticalSm,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Range & Page size
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(itemRangeText, style: theme.textTheme.bodySmall),
              if (!isMobile && onPageSizeChanged != null) ...[
                const SizedBox(width: AppSpacing.lg),
                Text('Rows per page:', style: theme.textTheme.bodySmall),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<int>(
                  value: pageSize,
                  underline: const SizedBox(),
                  isDense: true,
                  items: pageSizeOptions.map((size) {
                    return DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size', style: theme.textTheme.bodySmall),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onPageSizeChanged!(val);
                  },
                ),
              ],
            ],
          ),

          // Pagination navigation controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: hasPrevious
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Previous page',
                splashRadius: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : const Color(0xFFF1F5F9),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: hasNext
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Next page',
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
