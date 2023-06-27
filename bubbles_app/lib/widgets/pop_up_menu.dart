import 'package:bubbles_app/models/app_user.dart';
import 'package:bubbles_app/models/chat.dart';
import 'package:bubbles_app/providers/authentication_provider.dart';
import 'package:bubbles_app/services/database_service.dart';
import 'package:bubbles_app/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/message.dart';
import '../pages/chats/chat_page.dart';
// import '../pages/chats/chat_page.dart';

class PopupMenu {
  static Future<Chat> getChat(AppUser currentUser, AppUser otherUser) async {
    DatabaseService db = GetIt.instance.get<DatabaseService>();

    if (await db.doesChatExistForUsers(currentUser.uid, otherUser.uid)) {
      print('Chat already exists');
      QueryDocumentSnapshot<Map<String, dynamic>>? snapshot =
          await db.getChatForUser(currentUser.uid, otherUser.uid);

      if (snapshot != null) {
        List<Message> messages = [];
        QuerySnapshot bubbleMessage =
            await db.getLastMessageForBubble(snapshot.id);
        if (bubbleMessage.docs.isNotEmpty) {
          Map<String, dynamic> messageData =
              bubbleMessage.docs.first.data()! as Map<String, dynamic>;

          DocumentSnapshot userSnapshot =
              await db.getUser(messageData['sender']);
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          userData['uid'] = userSnapshot.id;
          AppUser sender = AppUser.fromJSON(userData);
          messageData['sender'] = sender;
          Message message = Message.fromJSON(messageData);
          messages.add(message);
        }

        return Chat(
          uid: snapshot.id,
          currentUserUid: currentUser.uid,
          members: [currentUser, otherUser],
          messages: messages,
          activity: false,
        );
      } else {
        throw Exception('Chat document does not exist');
      }
    } else {
      print('Creating chat');
      DocumentReference? doc = await db.createChat({
        "is_activity": false,
        "members": [currentUser.uid, otherUser.uid],
      });

      return Chat(
        uid: doc!.id,
        currentUserUid: currentUser.uid,
        members: [currentUser, otherUser],
        messages: [],
        activity: false,
      );
    }
  }

  static void showUserDetails(
      BuildContext context, AppUser user1, AppUser user2) {
    NavigationService navigation = GetIt.instance.get<NavigationService>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user2.imageURL),
              ),
              const SizedBox(height: 10),
              Text(user2.username),
              const SizedBox(height: 20),
              if (user1.uid != user2.uid)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    Chat chat = await PopupMenu.getChat(user1, user2);
                    navigation.goBack();
                    navigation.navigateToPage(ChatPage(chat: chat));
                  },
                  child: const Text('Open Private Chat'),
                ),
              if (user1.uid != user2.uid)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    DatabaseService db = GetIt.instance.get<DatabaseService>();
                    db.reportUser(user2.uid);
                    navigation.goBack();
                  },
                  child: Text(
                    'Report ${user2.username}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
