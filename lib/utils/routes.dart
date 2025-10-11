import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../screens/login/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/navigation/main_navigation_screen.dart';
import '../screens/navigation/admin_main_navigation_screen.dart';
import '../screens/dashboard/user_web_dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/control_settings_screen.dart';
import '../screens/admin/reports_admin_screen.dart';
import '../providers/auth_provider.dart';

class Routes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String userDashboard = '/user-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String history = '/history';
  static const String adminReports = '/admin-reports';
  static const String controlSettings = '/control-settings';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('Generating route for: ${settings.name}'); // Debug line
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoggedIn) {
                // Navigate to appropriate dashboard based on user role and platform
                if (authProvider.userProfile?.isAdmin == true) {
                  // Admin users get the same navigation interface
                  return AdminMainNavigationScreen();
                } else {
                  // Regular users get different interface based on platform
                  if (kIsWeb) {
                    return UserWebDashboardScreen();
                  } else {
                    return MainNavigationScreen();
                  }
                }
              }
              return LoginScreen();
            },
          ),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => SignupScreen(),
          settings: settings,
        );

      case userDashboard:
        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => AdminMainNavigationScreen(),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => HistoryScreen(),
          settings: settings,
        );

      case adminReports:
        return MaterialPageRoute(
          builder: (_) => ReportsAdminScreen(),
          settings: settings,
        );

      case controlSettings:
        return MaterialPageRoute(
          builder: (_) => ControlSettingsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
    }
  }

  // Helper method untuk navigasi berdasarkan role user
  static String getHomeRoute(String userRole) {
    return userRole == 'admin' ? adminDashboard : userDashboard;
  }
}
