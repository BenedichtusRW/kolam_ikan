import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/user_dashboard_screen.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/control_settings_screen.dart';

class Routes {
  // Route names
  static const String login = '/login';
  static const String userDashboard = '/user-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String history = '/history';
  static const String controlSettings = '/control-settings';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );

      case userDashboard:
        return MaterialPageRoute(
          builder: (_) => UserDashboardScreen(),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => HistoryScreen(),
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
            body: Center(
              child: Text('Page not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method untuk navigasi berdasarkan role user
  static String getHomeRoute(String userRole) {
    return userRole == 'admin' ? adminDashboard : userDashboard;
  }
}