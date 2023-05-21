import 'dart:math';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:bubbles_app/pages/bubbles/bubble_tile.dart';

import 'package:bubbles_app/pages/bubbles/create_bubble_page.dart';

//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../../models/bubble.dart';
import '../../networks/gps.dart';
import '../../providers/authentication_provider.dart';
import '../../providers/bubbles_page_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/rounded_image.dart';

//Services

//constants

class BubblesPage extends StatefulWidget {
  const BubblesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BubblesPageState();
  }
}

class _BubblesPageState extends State<BubblesPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late BubblesPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BubblesPageProvider>(
          create: (_) => BubblesPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<BubblesPageProvider>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bubbles'),
          ),
          body: Container(
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
                _bubblesList(),
                _createBubble(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bubblesList() {
    List<Bubble>? bubbles = _pageProvider.bubbles;
    return Expanded(
      child: (() {
        if (bubbles != null) {
          if (bubbles.isNotEmpty) {
            return ListView.builder(
              itemCount: bubbles.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    BubbleTile(bubble: bubbles[index]),
                    const SizedBox(height: 10)
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Bubbles Found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _createBubble() {
    return FloatingActionButton(
      onPressed: () {
        _navigation.navigateToPage(const CreateBubblePage());
      },
      child: const Icon(Icons.create),
    );
  }
}
