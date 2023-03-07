//Packages
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/app_user.dart';
import '../models/message.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required, required this.appUser});

  final AppUser appUser;

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatsPageProvider>();
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
              SizedBox(height: _deviceHeight * 0.05),
              _image(),
              SizedBox(height: _deviceHeight * 0.05),
              _details(),
              SizedBox(height: _deviceHeight * 0.05),
              _chatsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _image() {
    return RoundedImageNetwork(
      key: UniqueKey(),
      imagePath: widget.appUser.imageURL,
      size: _deviceHeight * 0.2,
    );
  }

  Widget _details() {
    return Column(
      children: [
        Text("Username: ${widget.appUser.username}"),
        Text("Email: ${widget.appUser.email}"),
        Text("Email: ${widget.appUser.lastActive}"),
        Text("Uid: ${widget.appUser.uid}"),
      ],
    );
  }

  Widget _chatsList() {
    List<Chat>? chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (chats != null) {
          if (chats.isNotEmpty) {
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _chatTile(
                  chats[index],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Chats Found.",
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

  Widget _chatTile(Chat chat) {
    List<AppUser> recepients = chat.recepients();
    bool isActive = recepients.any((d) => d.wasRecentlyActive());
    String subtitleText = "";
    if (chat.messages.isNotEmpty) {
      subtitleText = chat.messages.first.type != MessageType.text
          ? "Media Attachment"
          : chat.messages.first.content;
    }
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: chat.title(),
      subtitle: subtitleText,
      imagePath: chat.imageURL(),
      isActive: isActive,
      isActivity: chat.activity,
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: chat),
        );
      },
    );
  }
}
