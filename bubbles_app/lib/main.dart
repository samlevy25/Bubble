import 'package:flutter/material.dart';

// Packages
import 'package:provider/provider.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/home_page.dart';
import './pages/register_page.dart';

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
          const MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext context) {
            return AuthenticationProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bubbles',
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 86, 81, 249),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromARGB(255, 105, 101, 159)),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext context) => const LoginPage(),
          '/register': (BuildContext context) => const RegisterPage(),
          '/home': (BuildContext context) => const HomePage(),
        },
      ),
    );
  }
}
