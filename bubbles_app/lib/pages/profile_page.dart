import 'package:bubbles_app/models/app_user.dart';
import 'package:bubbles_app/pages/chats_page.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';
import '../services/navigation_service.dart';

import '../widgets/profile_widget.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
    return Builder(
      builder: (context) => Scaffold(
        body: ListView(
          children: [
            ProfileWidget(
              imagePath: _auth.appUser.imageURL,
              onClicked: () {},
            ),
            const SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_title(), _settingButton()]),
            const SizedBox(height: 24),
            _chats(),
          ],
        ),
      ),
    );
  }

  Widget _title() => Column(
        children: [
          Text(
            _auth.appUser.username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            _auth.appUser.email,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget _settingButton() {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        _navigation.navigateToPage(const SettingsPage());
      },
    );
  }

  Widget _chats() {
    return const ChatsPage();
  }
}
