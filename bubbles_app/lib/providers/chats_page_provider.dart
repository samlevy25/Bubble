import 'dart:async';

import 'package:bubbles_app/models/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';
import '../providers/authentication_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatsPageProvider extends ChangeNotifier {
  final AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;

  late StreamSubscription _chatsStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      _chatsStream = _db.getChatsForUser(_auth.appUser.uid).listen(
        (snapshot) async {
          if (snapshot.docs.isEmpty) {
            chats = null;
            notifyListeners();
            return;
          }

          chats = (await Future.wait(
            snapshot.docs.map(
              (d) async {
                Map<String, dynamic>? chatData =
                    d.data() as Map<String, dynamic>?;

                if (chatData == null) {
                  print('Invalid chat data');
                  return null;
                }

                List<AppUser> members = [];
                for (var mUid in chatData["members"]) {
                  print('Fetching user document for member: $mUid');
                  DocumentSnapshot userSnapshot = await _db.getUser(mUid);
                  if (userSnapshot.exists) {
                    var userData = userSnapshot.data();
                    if (userData is Map<String, dynamic>) {
                      userData["uid"] = userSnapshot.id;
                      members.add(AppUser.fromJSON(userData));
                      print(
                          'User document fetched successfully for member: $mUid');
                    } else {
                      print('Invalid user data format for member: $mUid');
                    }
                  } else {
                    print('User document not found for member: $mUid');
                  }
                }

                if (members.length < 2) {
                  print('Chat does not have at least two members');
                  return null;
                }

                List<Message> messages = [];
                QuerySnapshot bubbleMessage =
                    await _db.getLastMessageForBubble(d.id);
                if (bubbleMessage.docs.isNotEmpty) {
                  Map<String, dynamic>? messageData =
                      bubbleMessage.docs.first.data() as Map<String, dynamic>?;

                  if (messageData == null) {
                    print('Invalid message data for chat ${d.id}');
                    return null;
                  }

                  DocumentSnapshot userSnapshot =
                      await _db.getUser(messageData['sender']);
                  Map<String, dynamic>? userData =
                      userSnapshot.data() as Map<String, dynamic>?;

                  if (userData == null) {
                    print(
                        'Invalid user data for sender of message in chat ${d.id}');
                    return null;
                  }

                  userData['uid'] = userSnapshot.id;
                  AppUser sender = AppUser.fromJSON(userData);
                  messageData['sender'] = sender;
                  Message message = Message.fromJSON(messageData);
                  messages.add(message);
                }

                return Chat(
                  uid: d.id,
                  currentUserUid: _auth.appUser.uid,
                  members: members,
                  messages: messages,
                  activity: chatData["is_activity"],
                );
              },
            ),
          ))
              .whereType<Chat>()
              .toList();

          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting chats.");
        print(e);
      }
    }
  }
}
