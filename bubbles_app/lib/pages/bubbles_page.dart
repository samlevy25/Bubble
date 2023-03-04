import 'package:bubbles_app/pages/create_bubble_page.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default

//Packages
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../models/bubble.dart';
import '../providers/authentication_provider.dart';
import '../providers/bubbles_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import 'bubble_page.dart';

//Widgets
import '../widgets/top_bar.dart';

//Models
import '../models/app_user.dart';
import '../models/message.dart';

class BubblesPage extends StatefulWidget {
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
      builder: (BuildContext _context) {
        _pageProvider = _context.watch<BubblesPageProvider>();
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
    List<Bubble>? _bubbles = _pageProvider.bubbles;
    return Expanded(
      child: (() {
        if (_bubbles != null) {
          if (_bubbles.length != 0) {
            return ListView.builder(
              itemCount: _bubbles.length,
              itemBuilder: (BuildContext _context, int _index) {
                return _bubbleTile(
                  _bubbles[_index],
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

  Widget _bubbleTile(Bubble _bubble) {
    List<AppUser> _recepients = _bubble.recepients();
    bool _isActive = _recepients.any((_d) => _d.wasRecentlyActive());
    String _subtitleText = "";
    if (_bubble.messages.isNotEmpty) {
      _subtitleText = _bubble.messages.first.type != MessageType.text
          ? "Media Attachment"
          : _bubble.messages.first.content;
    }

    return Center(
      child: Card(
        color: const Color.fromARGB(204, 204, 252, 255),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: RoundedImageNetwork(
                imagePath: _bubble.getImageURL(),
                size: _deviceHeight * 0.06,
                key: UniqueKey(),
              ),
              title: Text(_bubble.getName()),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Memmbers: ${_bubble.members.length}"),
                  Text("Location: ${_bubble.getLocation()}"),
                  Text("Method: ${_bubble.getMethod()}"),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('Join'),
                  onPressed: () {
                    _bubble;
                    _navigation.navigateToPage(BubblePage(bubble: _bubble));
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Cancle'),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _map() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 47, 68, 106),
            width: 8,
          ), //Border.all
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(
                5.0,
                5.0,
              ), //OffsetblurRadius: 10.0,
              spreadRadius: 2.0,
            ), //BoxShadow
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ), //BoxShadow
          ],
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FlutterMap(
          options: MapOptions(
            zoom: 9.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ),
      ),
    );
  }

  Widget _createBubble() {
    return FloatingActionButton(
      onPressed: () {
        _navigation.navigateToPage(CreateBubblePage());
      },
      child: const Icon(Icons.add),
    );
  }
}
