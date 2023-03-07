import 'package:bubbles_app/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//p
import '../models/app_user.dart';

import '../providers/authentication_provider.dart';
import 'bubbles_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    final List<Widget> _pages = [
      const BubblesPage(),
      Container(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: _pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: "Bubbles", icon: Icon(Icons.circle)),
          BottomNavigationBarItem(label: "Empty", icon: Icon(Icons.square)),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  AppUser currentUser() {
    return Provider.of<AuthenticationProvider>(context).appUser;
  }
}
