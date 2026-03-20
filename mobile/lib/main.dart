import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dealer_dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'providers/dealer_provider.dart';
import 'providers/auth_provider.dart';
import 'models/user.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DealerProvider()),
      ],
      child: const GasManagementApp(),
    ),
  );
}

class GasManagementApp extends StatelessWidget {
  const GasManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepal Gas Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (auth.isAuthenticated) {
            if (auth.user?.role == UserRole.dealer) {
              return const DealerDashboardScreen();
            }
            return const MapScreen();
          }
          return const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
