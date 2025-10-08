import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/history_provider.dart';
import 'providers/reports_provider.dart';

// Utils
import 'utils/routes.dart';

// Screens
import 'screens/login/login_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/dashboard/user_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp(
        title: 'Kolam Ikan Monitor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: Routes.login,
        onGenerateRoute: Routes.generateRoute,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoggedIn) {
              // Navigate to appropriate dashboard based on user role
              if (authProvider.userProfile?.isAdmin == true) {
                return AdminDashboardScreen();
              } else {
                return UserDashboardScreen();
              }
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}