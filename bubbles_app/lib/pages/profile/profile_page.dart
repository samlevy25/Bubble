import 'package:bubbles_app/pages/profile/activity_list.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../providers/authentication_provider.dart';

import '../../services/navigation_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      body: Column(
        children: [
          _image(),
          _userDetails(),
          _userRate(),
          Expanded(
            child: _activityList(),
          ),
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

  Widget _userRate() {
    var x = _auth.appUser.upVotes;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Rate: ${x}%",
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _activityList() {
    return ActivityList(activities: _auth.appUser.activities);
  }
}
