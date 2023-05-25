import 'package:bubbles_app/pages/map/map_page.dart';
import 'package:bubbles_app/pages/profile/profile_page.dart';
import 'package:bubbles_app/pages/profile/settings_page.dart';
import 'package:bubbles_app/pages/space/explorer_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/navigation_service.dart';
import 'bubbles/bubbles_page.dart';
import 'chats/chats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;

  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _navigation = GetIt.instance.get<NavigationService>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Set the elevation to 0 to remove the line
        leading: IconButton(
          icon: Icon(Icons.notifications),
          color: Colors.lightBlue,
          onPressed: () {
            // Handle notification icon press
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.lightBlue,
            onPressed: () {
              _navigation.navigateToPage(const SettingsPage());
            },
          ),
        ],
        title: Center(
          child: Image.asset(
            'assets/images/logo.png', // Replace 'assets/logo.png' with your image path
            width: 40,
            height: 40,
          ),
        ),
      ),
      body: _buildPage(currentPage),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            label: 'Local',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0, // Set the elevation to 0 to remove the line
              title: const TabBar(
                indicatorSize:
                    TabBarIndicatorSize.label, // Set indicator size to label
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 2.0,
                      color: Colors.blue), // Set transparent border color
                ),
                labelColor: Colors.white, // Set the label (selected tab) color
                unselectedLabelColor:
                    Colors.grey, // Set the unselected tab label color
                labelPadding: EdgeInsets.symmetric(
                    horizontal: 16), // Adjust label padding to reduce tab size
                tabs: [
                  Tab(
                    child: Text(
                      'Bubbles',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // Adjust font size for smaller tabs
                      ), // Set the text color for the tab
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Explorer',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // Adjust font size for smaller tabs
                      ), // Set the text color for the tab
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                BubblesPage(),
                ExplorerPage(),
              ],
            ),
          ),
        );
      case 1:
        return const MapPage();
      case 2:
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0, // Set the elevation to 0 to remove the line
              backgroundColor: Colors.white,
              title: const TabBar(
                indicatorSize:
                    TabBarIndicatorSize.label, // Set indicator size to label
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 2.0,
                      color: Colors.blue), // Set transparent border color
                ),
                labelColor: Colors.grey, // Set the label (selected tab) color
                unselectedLabelColor:
                    Colors.black, // Set the unselected tab label color
                labelPadding: EdgeInsets.symmetric(
                    horizontal: 16), // Adjust label padding to reduce tab size
                tabs: [
                  Tab(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // Adjust font size for smaller tabs
                      ), // Set the text color for the tab
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // Adjust font size for smaller tabs
                      ), // Set the text color for the tab
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ProfilePage(),
                ChatsPage(),
              ],
            ),
          ),
        );

      default:
        return Container();
    }
  }
}
