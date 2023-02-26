//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../models/bubble.dart';
import '../providers/authentication_provider.dart';
import '../providers/bubbles_page_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

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
              TopBar(
                'Bubbles',
                primaryAction: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  onPressed: () {
                    _auth.logout();
                  },
                ),
              ),
              _bubblesList(),
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
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: _bubble.title(),
      subtitle: _subtitleText,
      imagePath: _bubble.imageURL(),
      isActive: _isActive,
      isActivity: _bubble.activity,
      onTap: () {
        _navigation.navigateToPage(BubblesPage());
      },
    );
  }
}
