import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/first_login_change_password_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_history_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/sessions_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/foundation/screens/component_showcase_screen.dart';
import '../../features/foundation/screens/foundation_dashboard_screen.dart';
import '../../features/foundation/screens/system_status_screen.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_responsive_layout.dart';
import 'route_paths.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final List<NavItem> navItems = [
    const NavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: RoutePaths.dashboard,
    ),
    const NavItem(
      title: 'Active Sessions',
      icon: Icons.devices_outlined,
      route: RoutePaths.sessions,
    ),
    const NavItem(
      title: 'Login History',
      icon: Icons.history_outlined,
      route: RoutePaths.loginHistory,
    ),
    const NavItem(
      title: 'System Status',
      icon: Icons.monitor_heart_outlined,
      route: RoutePaths.systemStatus,
    ),
    const NavItem(
      title: 'UI Showcase',
      icon: Icons.widgets_outlined,
      route: RoutePaths.componentShowcase,
    ),
  ];

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RoutePaths.dashboard,
      refreshListenable: authProvider,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final path = state.uri.path;
        final isAuthenticated = authProvider.isAuthenticated;
        final mustChangePassword = authProvider.mustChangePassword;

        final isPublicRoute =
            path == RoutePaths.login ||
            path == RoutePaths.forgotPassword ||
            path == RoutePaths.resetPassword ||
            path == RoutePaths.verifyEmail ||
            path == RoutePaths.otp;

        // 1. Unauthenticated users cannot access protected routes
        if (!isAuthenticated) {
          return isPublicRoute ? null : RoutePaths.login;
        }

        // 2. Authenticated users with mustChangePassword flag must change password first
        if (mustChangePassword) {
          return path == RoutePaths.firstLoginChangePassword
              ? null
              : RoutePaths.firstLoginChangePassword;
        }

        // 3. Authenticated active users should not see login/forgot/reset screens
        if (isPublicRoute || path == RoutePaths.firstLoginChangePassword) {
          return RoutePaths.dashboard;
        }

        return null;
      },
      routes: [
        // Public Unauthenticated Routes
        GoRoute(
          path: RoutePaths.login,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginScreen()),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ForgotPasswordScreen()),
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          pageBuilder: (context, state) {
            final token = state.uri.queryParameters['token'];
            return NoTransitionPage(
              child: ResetPasswordScreen(initialToken: token),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.verifyEmail,
          pageBuilder: (context, state) {
            final token = state.uri.queryParameters['token'];
            return NoTransitionPage(
              child: VerifyEmailScreen(initialToken: token),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.otp,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: OtpScreen()),
        ),
        GoRoute(
          path: RoutePaths.firstLoginChangePassword,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FirstLoginChangePasswordScreen()),
        ),

        // Protected Application Shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppResponsiveLayout(
              currentRoute: state.uri.path,
              navItems: navItems,
              onNavigate: (route) {
                if (state.uri.path != route) {
                  context.go(route);
                }
              },
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: FoundationDashboardScreen()),
            ),
            GoRoute(
              path: RoutePaths.systemStatus,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SystemStatusScreen()),
            ),
            GoRoute(
              path: RoutePaths.componentShowcase,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ComponentShowcaseScreen()),
            ),
            GoRoute(
              path: RoutePaths.sessions,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SessionsScreen()),
            ),
            GoRoute(
              path: RoutePaths.loginHistory,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: LoginHistoryScreen()),
            ),
            GoRoute(
              path: RoutePaths.changePassword,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ChangePasswordScreen()),
            ),
          ],
        ),
      ],
    );
  }
}
