import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_empty_state.dart';
import 'app_loading.dart';

class AppTableColumn {
  final String label;
  final String? tooltip;
  final bool numeric;
  final bool sortable;

  const AppTableColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    this.sortable = false,
  });
}

class AppDataTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String? emptyMessage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading && rows.isEmpty) {
      return const Padding(
        padding: AppSpacing.insetAllXxl,
        child: AppLoading(message: 'Loading table data...'),
      );
    }

    if (!isLoading && rows.isEmpty) {
      return AppEmptyState(title: 'No Records Found', message: emptyMessage);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                headingRowHeight: 46.0,
                dataRowMinHeight: 48.0,
                dataRowMaxHeight: 56.0,
                columns: columns.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final col = entry.value;
                  return DataColumn(
                    label: Text(col.label),
                    tooltip: col.tooltip,
                    numeric: col.numeric,
                    onSort: col.sortable && onSort != null
                        ? (columnIndex, ascending) => onSort!(idx, ascending)
                        : null,
                  );
                }).toList(),
                rows: rows.map((rowCells) {
                  return DataRow(
                    cells: rowCells.map((cell) => DataCell(cell)).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
