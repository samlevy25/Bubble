import 'package:flutter/material.dart';

// Packages
import 'package:firebase_analytics/firebase_analytics.dart';

//Pages
import './pages/splash_page.dart';

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
        backgroundColor: Color.fromARGB(255, 0, 128, 255),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 5, 34),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(242, 255, 0, 1),
        ),
      ),
      // navigatorKey: NavigationService.navigatorKey,
    );
  }
}
