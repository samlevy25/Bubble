import 'package:flutter/material.dart';

// Packages
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';

//Servies
import './services/navigation_server.dart';

//Provider
import './providers/authentication_provider.dart';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(
          MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bubbles',
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 220, 223, 8),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.yellow),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
        },
      ),
    );
  }
}
