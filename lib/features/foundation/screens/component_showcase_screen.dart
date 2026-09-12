import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_data_table.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_pagination.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_text_field.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _buttonsLoading = false;
  String? _selectedDropdownValue = 'dev';
  String _searchQuery = '';
  int _currentPage = 1;
  int _pageSize = 5;
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  final List<Map<String, dynamic>> _demoTableData = [
    {
      'id': 'ADM-001',
      'name': 'Academics Foundation',
      'owner': 'Core Team',
      'status': 'Active',
      'priority': 'High',
    },
    {
      'id': 'ADM-002',
      'name': 'Student Information System',
      'owner': 'SIS Team',
      'status': 'Planning',
      'priority': 'Critical',
    },
    {
      'id': 'ADM-003',
      'name': 'Finance & Fee Billing',
      'owner': 'Finance Team',
      'status': 'Planning',
      'priority': 'High',
    },
    {
      'id': 'ADM-004',
      'name': 'Attendance Tracker',
      'owner': 'Operations Team',
      'status': 'Backlog',
      'priority': 'Medium',
    },
    {
      'id': 'ADM-005',
      'name': 'Timetable Generator',
      'owner': 'Academic Team',
      'status': 'Backlog',
      'priority': 'Medium',
    },
    {
      'id': 'ADM-006',
      'name': 'Parent Portal App',
      'owner': 'Mobile Team',
      'status': 'Backlog',
      'priority': 'Low',
    },
    {
      'id': 'ADM-007',
      'name': 'Examinations & Grading',
      'owner': 'Evaluation Team',
      'status': 'Planning',
      'priority': 'High',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredData = _demoTableData.where((row) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return row['name'].toString().toLowerCase().contains(q) ||
          row['id'].toString().toLowerCase().contains(q) ||
          row['owner'].toString().toLowerCase().contains(q);
    }).toList();

    filteredData.sort((a, b) {
      final key = _sortColumnIndex == 1 ? 'name' : 'id';
      final valA = a[key].toString();
      final valB = b[key].toString();
      return _sortAscending ? valA.compareTo(valB) : valB.compareTo(valA);
    });

    final totalCount = filteredData.length;
    final startIndex = ((_currentPage - 1) * _pageSize).clamp(0, totalCount);
    final endIndex = (_currentPage * _pageSize).clamp(0, totalCount);
    final pagedRows = filteredData.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      padding: AppSpacing.insetAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Design System & Component Showcase',
            subtitle:
                'Living style guide of all accessible, theme-aware Material 3 components',
            breadcrumbs: const [
              BreadcrumbItem(label: 'Home'),
              BreadcrumbItem(label: 'UI Components'),
            ],
            actions: [
              AppButton(
                text: _buttonsLoading
                    ? 'Reset Loading'
                    : 'Toggle Button Loading',
                icon: const Icon(Icons.hourglass_top, size: 16),
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  setState(() {
                    _buttonsLoading = !_buttonsLoading;
                  });
                },
              ),
            ],
          ),

          // 1. AppButton Showcase
          AppCard(
            title: 'AppButton Variants & Sizes',
            subtitle:
                'Accessible with Plus Jakarta Sans 600 weight, hover states, and loading states',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(
                  text: 'Primary Button',
                  isLoading: _buttonsLoading,
                  icon: const Icon(Icons.check, size: 16),
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Secondary Button',
                  variant: AppButtonVariant.secondary,
                  isLoading: _buttonsLoading,
                  icon: const Icon(Icons.bolt, size: 16),
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Outline Button',
                  variant: AppButtonVariant.outline,
                  isLoading: _buttonsLoading,
                  icon: const Icon(Icons.layers_outlined, size: 16),
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Ghost Button',
                  variant: AppButtonVariant.ghost,
                  isLoading: _buttonsLoading,
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Danger Button',
                  variant: AppButtonVariant.danger,
                  isLoading: _buttonsLoading,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Small',
                  size: AppButtonSize.sm,
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Large',
                  size: AppButtonSize.lg,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 2. Form Inputs Showcase
          AppCard(
            title: 'Form Inputs & Controls',
            subtitle:
                'Theme-aware AppTextField, AppDropdown, and debounced AppSearchField',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Standard Input',
                        hintText: 'Enter value...',
                        prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: AppTextField(
                        label: 'Password Input',
                        hintText: 'Enter secret...',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Environment Selector',
                        value: _selectedDropdownValue,
                        items: const [
                          AppDropdownItem(
                            value: 'dev',
                            label: 'Development (Port 4000)',
                            icon: Icon(Icons.developer_mode, size: 18),
                          ),
                          AppDropdownItem(
                            value: 'staging',
                            label: 'Staging Gateway',
                            icon: Icon(Icons.cloud_queue, size: 18),
                          ),
                          AppDropdownItem(
                            value: 'prod',
                            label: 'Production Enterprise',
                            icon: Icon(Icons.cloud_done, size: 18),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedDropdownValue = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Debounced Search',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppSearchField(
                            hintText: 'Filter ERP modules...',
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query;
                                _currentPage = 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Active Search Filter: "$_searchQuery"',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 3. AppDataTable & Pagination
          AppCard(
            title: 'AppDataTable & AppPagination',
            subtitle:
                'Enterprise responsive table with sortable columns and pagination',
            child: Column(
              children: [
                AppDataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: (colIdx, ascending) {
                    setState(() {
                      _sortColumnIndex = colIdx;
                      _sortAscending = ascending;
                    });
                  },
                  columns: const [
                    AppTableColumn(label: 'Module Code', sortable: true),
                    AppTableColumn(label: 'Module Name', sortable: true),
                    AppTableColumn(label: 'Assigned Team'),
                    AppTableColumn(label: 'Status'),
                    AppTableColumn(label: 'Priority'),
                  ],
                  rows: pagedRows.map((row) {
                    final statusColor = row['status'] == 'Active'
                        ? AppColors.success
                        : (row['status'] == 'Planning'
                              ? AppColors.info
                              : AppColors.warning);

                    return [
                      Text(
                        row['id']!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(row['name']!),
                      Text(row['owner']!),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          row['status']!,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(row['priority']!),
                    ];
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPagination(
                  currentPage: _currentPage,
                  totalItems: totalCount,
                  pageSize: _pageSize,
                  pageSizeOptions: const [5, 10, 20],
                  onPageChanged: (newPage) {
                    setState(() {
                      _currentPage = newPage;
                    });
                  },
                  onPageSizeChanged: (newSize) {
                    setState(() {
                      _pageSize = newSize;
                      _currentPage = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 4. Modal Dialogs & Feedback
          AppCard(
            title: 'AppDialog & Modals',
            subtitle: 'Standard accessible dialog foundation',
            child: Row(
              children: [
                AppButton(
                  text: 'Open Confirmation Dialog',
                  icon: const Icon(Icons.open_in_new, size: 16),
                  onPressed: () async {
                    final confirmed = await AppDialog.showConfirmation(
                      context: context,
                      title: 'Confirm Action',
                      message:
                          'Are you sure you want to trigger this action? This modal follows Material 3 guidelines.',
                      confirmText: 'Yes, Proceed',
                      cancelText: 'Cancel',
                    );
                    if (context.mounted && confirmed == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Action confirmed in AppDialog!'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  text: 'Open Destructive Dialog',
                  variant: AppButtonVariant.danger,
                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                  onPressed: () async {
                    await AppDialog.showConfirmation(
                      context: context,
                      title: 'Delete Resource Confirmation',
                      message:
                          'This is an example of a destructive dialog modal.',
                      confirmText: 'Delete',
                      isDestructive: true,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 5. Global States Preview (Loading, Empty, Error)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  title: 'AppLoading & Skeleton',
                  child: Column(
                    children: const [
                      AppLoading(message: 'Processing request...'),
                      SizedBox(height: AppSpacing.lg),
                      AppSkeletonLoader(width: double.infinity, height: 18),
                      SizedBox(height: AppSpacing.xs),
                      AppSkeletonLoader(width: double.infinity, height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppCard(
                  title: 'AppEmptyState',
                  child: AppEmptyState(
                    title: 'No Data to Show',
                    message: 'Records will appear here once configured.',
                    actionText: 'Add New Record',
                    onAction: () {},
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppCard(
                  title: 'AppErrorState',
                  child: AppErrorState(
                    title: 'Connection Timed Out',
                    message: 'The server took too long to respond.',
                    errorCode: 'TIMEOUT_ERROR',
                    onRetry: () {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
