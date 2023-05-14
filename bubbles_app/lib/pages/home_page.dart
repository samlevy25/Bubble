import 'package:bubbles_app/pages/profile_page.dart';
import 'package:bubbles_app/pages/space/explorer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

//p
import '../models/app_user.dart';

import '../providers/authentication_provider.dart';
import 'bubbles/bubbles_page.dart';

import 'chats/chats_page.dart';

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
      Container(), // place holder for chats
      const ChatsPage(),
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
            icon: const Icon(Icons.bubble_chart, color: Colors.blue),
            title: const Text('Bubbles'),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.feed, color: Colors.blue),
            title: const Text("Explorer"),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.explore, color: Colors.blue),
            title: const Text("Explore"),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.chat, color: Colors.blue),
            title: const Text("Chats"),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.person, color: Colors.blue),
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
