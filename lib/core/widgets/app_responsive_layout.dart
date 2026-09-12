import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../router/route_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_utils.dart';

class NavItem {
  final String title;
  final IconData icon;
  final String route;

  const NavItem({required this.title, required this.icon, required this.route});
}

class AppResponsiveLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final List<NavItem> navItems;
  final void Function(String route) onNavigate;

  const AppResponsiveLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.navItems,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final device = ResponsiveUtils.getDeviceType(context);

    if (device == DeviceType.mobile) {
      return _buildMobileLayout(context, theme, isDark);
    } else if (device == DeviceType.tablet) {
      return _buildTabletLayout(context, theme, isDark);
    } else {
      return _buildDesktopLayout(context, theme, isDark);
    }
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryDarkTheme
                    : AppColors.primaryLight,
                borderRadius: AppRadius.borderSm,
              ),
              child: const Icon(Icons.school, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Schoolaora ERP',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [_buildThemeToggle(context, isDark)],
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              _buildSidebarHeader(context, isDark),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: AppSpacing.insetAllSm,
                  children: navItems.map((item) {
                    final isSelected = currentRoute == item.route;
                    return _buildNavItemTile(item, isSelected, isDark, () {
                      Navigator.of(context).pop();
                      onNavigate(item.route);
                    });
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getSelectedIndex(),
        onTap: (index) => onNavigate(navItems[index].route),
        selectedItemColor: isDark
            ? AppColors.primaryDarkTheme
            : AppColors.primaryLight,
        unselectedItemColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        backgroundColor: theme.colorScheme.surface,
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }

  // --- Tablet Layout ---
  Widget _buildTabletLayout(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _getSelectedIndex(),
            onDestinationSelected: (index) => onNavigate(navItems[index].route),
            labelType: NavigationRailLabelType.all,
            backgroundColor: theme.colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDarkTheme
                      : AppColors.primaryLight,
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(Icons.school, size: 20, color: Colors.white),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _buildThemeToggle(context, isDark),
                ),
              ),
            ),
            destinations: navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.title),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, theme, isDark, isDesktop: false),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarHeader(context, isDark),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    'PHASE 1 FOUNDATION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: AppSpacing.insetAllSm,
                    children: navItems.map((item) {
                      final isSelected = currentRoute == item.route;
                      return _buildNavItemTile(
                        item,
                        isSelected,
                        isDark,
                        () => onNavigate(item.route),
                      );
                    }).toList(),
                  ),
                ),
                _buildSidebarFooter(theme, isDark),
              ],
            ),
          ),

          // Main Area
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, theme, isDark, isDesktop: true),
                Expanded(
                  child: Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryDarkTheme
                  : AppColors.primaryLight,
              borderRadius: AppRadius.borderMd,
            ),
            child: const Icon(Icons.school, size: 22, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Schoolaora',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Enterprise ERP',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(ThemeData theme, bool isDark) {
    return Container(
      padding: AppSpacing.insetAllMd,
      margin: AppSpacing.insetAllSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Phase 2 Active',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Auth & Security Architecture',
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemTile(
    NavItem item,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    final activeBg = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.15)
        : AppColors.primaryLight.withValues(alpha: 0.1);
    final activeColor = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLight;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.textDark : AppColors.textLight)
                          : inactiveColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required bool isDesktop,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Axionexa Schoolaora ERP Platform',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDarkTheme.withValues(alpha: 0.2)
                      : AppColors.primaryTint,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  'v1.0.0-Phase2',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryDarkTheme
                        : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildThemeToggle(context, isDark),
              const SizedBox(width: AppSpacing.sm),
              _buildUserMenu(context, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return TextButton.icon(
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign In'),
            onPressed: () => onNavigate(RoutePaths.login),
          );
        }

        final user = auth.currentUser;
        final initial = (user?.firstName.isNotEmpty == true)
            ? user!.firstName[0].toUpperCase()
            : 'U';

        return PopupMenuButton<String>(
          tooltip: 'Account Settings',
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'sessions':
                onNavigate(RoutePaths.sessions);
                break;
              case 'history':
                onNavigate(RoutePaths.loginHistory);
                break;
              case 'change_password':
                onNavigate(RoutePaths.changePassword);
                break;
              case 'logout':
                await auth.logout();
                onNavigate(RoutePaths.login);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Authenticated User',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'sessions',
              child: Row(
                children: [
                  Icon(Icons.devices_rounded, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Active Sessions'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Login History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'change_password',
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Change Password'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                  SizedBox(width: AppSpacing.sm),
                  Text('Sign Out', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? AppColors.primaryDarkTheme.withValues(alpha: 0.2)
                    : AppColors.primaryTint,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primaryDarkTheme
                        : AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProv, _) {
        return Tooltip(
          message: themeProv.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
          child: IconButton(
            icon: Icon(
              themeProv.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () => themeProv.toggleTheme(),
          ),
        );
      },
    );
  }

  int _getSelectedIndex() {
    final idx = navItems.indexWhere((item) => item.route == currentRoute);
    return idx >= 0 ? idx : 0;
  }
}
