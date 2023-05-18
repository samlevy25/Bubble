import 'package:bubbles_app/pages/map_page.dart';
import 'package:bubbles_app/pages/profile_page.dart';
import 'package:bubbles_app/pages/space/explorer_page.dart';
import 'package:flutter/material.dart';

import 'bubbles/bubbles_page.dart';
import 'chats/chats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 2;

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    final List<Widget> pages = [
      const BubblesPage(),
      const ExplorerPage(),
      const MapPage(), // place holder for chats
      const ChatsPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) => setState(() {
          currentPage = index;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            label: 'Bubbles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
