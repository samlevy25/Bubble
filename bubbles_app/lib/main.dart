import 'package:flutter/material.dart';

// Packages
import 'package:firebase_analytics/firebase_analytics.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';

//Servies
import './services/navigation_server.dart';

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
    return MaterialApp(
      title: 'Bubbles',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.red,
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(backgroundColor: Colors.yellow),
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext _context) => LoginPage(),
      },
    );
  }
}
