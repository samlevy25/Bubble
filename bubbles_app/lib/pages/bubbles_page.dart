import 'package:bubbles_app/pages/bubble_page.dart';
import 'package:bubbles_app/pages/create_bubble_page.dart';

//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/bubbles_page_provider.dart';

//Services
import '../services/navigation_service.dart';
import '../services/map_service.dart';

//Models
import '../models/bubble.dart';
import '../widgets/rounded_image.dart';

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
              _bubblesList(),
              _map(),
              _createBubble(),
            ],
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
                return _bubbleTile(bubbles[index]);
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

  Widget _map() {
    return const BubblesMap();
  }

  Widget _createBubble() {
    return FloatingActionButton(
      onPressed: () {
        _navigation.navigateToPage(const CreateBubblePage());
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _bubbleTile(Bubble bubble) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: Card(
            color: const Color.fromARGB(204, 104, 225, 234),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(bubble.getName()),
                  leading: RoundedImageNetwork(
                    imagePath: bubble.getImageURL(),
                    size: _deviceHeight * 0.06,
                    key: UniqueKey(),
                  ),
                )
              ],
            ),
          ),
          onPressed: () => {
            bubble.joinMemmber(_auth.appUser).then((value) =>
                _navigation.navigateToPage(BubblePage(bubble: bubble)))
          },
        ),
      ],
    );
  }
}
