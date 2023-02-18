import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//p
import '../providers/authentication_provider.dart';

//w
import '../widgets/top_bar.dart';

class BubblesPage extends StatefulWidget {
  const BubblesPage({super.key});

  @override
  State<BubblesPage> createState() => _BubblesPageState();
}

class _BubblesPageState extends State<BubblesPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.02,
      ),
      height: _deviceHeight * 0.98,
      width: _deviceWidth * 0.97,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TopBar(
            'Bubbles',
            primaryAction: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Color.fromRGBO(0, 82, 218, 1.0),
              ),
              onPressed: () {
                _auth.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
