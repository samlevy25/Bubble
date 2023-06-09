import 'dart:math';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/pages/bubbles/bubble_page.dart';
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

import '../../networks/wifi.dart';

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
  bool showPasswordInput = false;
  TextEditingController passwordController = TextEditingController();

  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late BubblesPageProvider _pageProvider;

  String? _geohash;
  String? _bssid;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
  }

  Future<void> _fetchLocationData() async {
    _geohash = await getCurrentGeoHash(22);
    _bssid = (await getWifiBSSID())!;
  }

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
      child: FutureBuilder<void>(
        future: _fetchLocationData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildUI();
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<BubblesPageProvider>();
        return Scaffold(
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
    print("Bubbles List");
    List<Bubble>? bubbles = _pageProvider.bubbles;
    return Expanded(
      child: (() {
        if (bubbles != null) {
          print("not null");
          if (bubbles.isNotEmpty) {
            return ListView(
              children: bubbles.map((bubble) {
                // Add a condition to filter or exclude specific bubbles
                if (isBubbleNearby(bubble)) {
                  return GestureDetector(
                    onTap: () {
                      _showBubbleDetailsBottomSheet(bubble);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: _deviceWidth * 0.8,
                          height: _deviceHeight * 0.1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: bubble.keyType.gradient,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: RoundedImageNetwork(
                                    key: UniqueKey(),
                                    imagePath: bubble.image,
                                    size: _deviceHeight * 0.05,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bubble.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(
                                    bubble.keyType.icon,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Skip rendering the bubble
                }
              }).toList(),
            );
          } else {
            return const Center(
              child: Text(
                "No Bubbles Found",
                style: TextStyle(color: Colors.lightBlue, fontSize: 20),
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

  void _showBubbleDetailsBottomSheet(Bubble bubble) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: bubble.keyType.gradient,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    RoundedImageNetwork(
                      key: UniqueKey(),
                      imagePath: bubble.image,
                      size: _deviceHeight * 0.1,
                    ),
                    Text(
                      bubble.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bubble.description,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Bubble Location",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Bubble Length",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    if (bubble.keyType == BubbleKeyType.password) {
                      print("Password");
                    } else if (bubble.keyType == BubbleKeyType.nfc) {
                      print("NFC");
                    } else {
                      _navigation.navigateToPage(BubblePage(bubble: bubble));
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  bool isBubbleNearby(Bubble bubble) {
    if (_geohash == null) {
      // Location data not available
      return false;
    }

    if (!_geohash!.contains(bubble.geohash)) {
      // Bubble is not nearby
      return false;
    }
    if (bubble.keyType == BubbleKeyType.wifi) {
      // Bubble requires Wi-Fi connection
      return bubble.key == _bssid;
    }
    if (bubble.keyType == BubbleKeyType.bluetooth) {
      // Bubble requires Bluetooth connection
      return bubble.key == "bt";
    } else {
      // Bubble doesn't require Wi-Fi or Bluetooth
      return true;
    }
  }
}
