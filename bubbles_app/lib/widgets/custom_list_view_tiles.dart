//Packages
import 'package:bubbles_app/models/comment.dart';
import 'package:bubbles_app/models/post.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';

//Widgets
import '../models/chat.dart';
import '../pages/chats/chat_page.dart';
import '../services/navigation_service.dart';
import '../widgets/rounded_image.dart';
import '../widgets/message_bubbles.dart';

//Models
import '../models/message.dart';
import '../models/app_user.dart';

//

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  const CustomListViewTile({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        size: height / 2,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  const CustomListViewTileWithActivity({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.blue, // set the background color of the container
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15.0), // set the corner radius of the container
        ),
      ),
      child: ListTile(
        onTap: () => onTap(),
        minVerticalPadding: height * 0.20,
        leading: RoundedImageNetworkWithStatusIndicator(
          key: UniqueKey(),
          size: height / 2,
          imagePath: imagePath,
          isActive: isActive,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isActivity
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(
                    color: Colors.white,
                    size: height * 0.10,
                  ),
                ],
              )
            : Text(
                subtitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
      ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final Message message;
  final AppUser sender;

  late NavigationService _navigation;

  CustomChatListViewTile({
    super.key,
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  });
  @override
  Widget build(BuildContext context) {
    _navigation = GetIt.instance.get<NavigationService>();
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !isOwnMessage
              ? GestureDetector(
                  child: RoundedImageNetwork(
                      key: UniqueKey(),
                      imagePath: sender.imageURL,
                      size: width * 0.08),
                  onLongPress: () {
                    if (kDebugMode) {
                      _navigation.navigateToPage(ChatPage(
                          chat: Chat(
                              activity: false,
                              currentUserUid: "x",
                              group: false,
                              members: [],
                              messages: [],
                              uid: 'x')));
                    }
                  },
                )
              : Container(),
          SizedBox(
            width: width * 0.05,
          ),
          Column(
            children: [
              GestureDetector(
                child: Column(
                  children: [
                    message.type == MessageType.text
                        ? TextMessageBubble(
                            isOwnMessage: isOwnMessage,
                            message: message,
                            height: deviceHeight * 0.06,
                            width: width,
                          )
                        : ImageMessageBubble(
                            isOwnMessage: isOwnMessage,
                            message: message,
                            height: deviceHeight * 0.30,
                            width: width * 0.55,
                          ),
                  ],
                ),
                onTap: () {
                  if (isOwnMessage) {
                    Container(
                      color: Colors.purple,
                    );
                  } else {
                    Container(
                      color: Colors.purple,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomExplorerListViewTile extends StatelessWidget {
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final Post post;

  late NavigationService _navigation;

  CustomExplorerListViewTile({
    super.key,
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.post,
  });
  @override
  Widget build(BuildContext context) {
    _navigation = GetIt.instance.get<NavigationService>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Add this line
          children: [
            RoundedImageNetwork(
              key: UniqueKey(),
              imagePath:
                  "https://fastly.picsum.photos/id/361/200/300.jpg?hmac=unS_7uvpA3Q-hJTvI1xNCnlhta-oC6XnWZ4Y11UpjAo",
              size: width * 0.08,
            ),
            Expanded(
              child: post.type == PostType.text
                  ? TextPostBubble(
                      post: post,
                      height: deviceHeight * 0.06,
                      width: width,
                    )
                  : ImagePostBubble(
                      post: post,
                      height: deviceHeight * 0.30,
                      width: width * 0.55,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
