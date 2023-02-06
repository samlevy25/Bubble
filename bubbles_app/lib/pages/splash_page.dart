import 'package:flutter/material.dart';

//Packegs
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/navigation_server.dart';
import '../services/media_service.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    required key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _setup().then(
      (_) => widget.onInitializationComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubbles',
      theme: ThemeData(),
      home: Scaffold(
        body: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/b.jpeg'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _registerServices();
  }
}

void _registerServices() {
  GetIt.instance.registerSingleton<NavigationService>(
    NavigationService(),
  );

  GetIt.instance.registerSingleton<MediaService>(
    MediaService(),
  );
}
