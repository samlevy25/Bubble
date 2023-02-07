import 'package:flutter/material.dart';

// Packages
import 'package:firebase_analytics/firebase_analytics.dart';

//Pages
import './pages/splash_page.dart';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {},
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubbles',
      theme: ThemeData(),
    );
  }
}
