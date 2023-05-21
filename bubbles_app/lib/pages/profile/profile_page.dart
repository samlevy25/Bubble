import 'package:bubbles_app/pages/profile/activity_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/app_user.dart';
import '../../providers/authentication_provider.dart';
import '../../providers/chats_page_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/profile_widget.dart';
import '../chats/chats_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: _actions(),
      ),
      body: Column(
        children: [
          _image(),
          _userDetails(),
          Expanded(child: _activityList()),
        ],
      ),
    );
  }

  Widget _image() {
    return Container(
      height: _deviceHeight * 0.2,
      width: _deviceWidth * 0.4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(_auth.appUser.imageURL),
        ),
      ),
    );
  }

  Widget _userDetails() {
    return Column(
      children: [
        Text(
          _auth.appUser.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          _auth.appUser.email,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  List<Widget> _actions() {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      IconButton(
        onPressed: () {
          _navigation.navigateToPage(const SettingsPage());
        },
        icon: const Icon(Icons.settings),
      ),
    ];
  }

  Widget _activityList() {
    // Generate some sample activities
    List<Activity> activities = [
      Activity('Activity 1', DateTime.now()),
      Activity('Activity 2', DateTime.now()),
      Activity('Activity 3', DateTime.now()),
    ];

    return ActivityList(activities: activities);
  }
}
