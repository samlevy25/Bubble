import 'package:bubbles_app/pages/explorer_page.dart';
import 'package:bubbles_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

//p
import '../models/user.dart';

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
    // ignore: no_leading_underscores_for_local_identifiers
    final List<Widget> _pages = [
      const BubblesPage(),
      const ExplorerPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: _pages[currentPage],
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: currentPage,
        iconSize: 30,
        showElevation: false,
        onItemSelected: (index) => setState(() {
          currentPage = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.circle),
            title: const Text('Bubbles'),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.square),
            title: const Text("Empty"),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
          ),
        ],
      ),
    );
  }

  AppUser currentUser() {
    return Provider.of<AuthenticationProvider>(context).appUser;
  }
}
