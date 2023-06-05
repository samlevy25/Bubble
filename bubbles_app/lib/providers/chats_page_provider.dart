import 'dart:async';

//Packages
import 'package:bubbles_app/models/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../services/database_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
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
          chats = await Future.wait(
            snapshot.docs.map(
              (d) async {
                Map<String, dynamic> chatData =
                    d.data() as Map<String, dynamic>;
                //Get Users In Chat
                List<AppUser> members = [];
                // ignore: no_leading_underscores_for_local_identifiers
                for (var mUid in chatData["members"]) {
                  DocumentSnapshot userSnapshot = await _db.getUser(mUid);
                  Map<String, dynamic> userData =
                      userSnapshot.data() as Map<String, dynamic>;
                  userData["uid"] = userSnapshot.id;
                  members.add(
                    AppUser.fromJSON(userData),
                  );
                }
                //Get Last Message For Chat
                List<Message> messages = [];
                QuerySnapshot bubbleMessage =
                    await _db.getLastMessageForBubble(d.id);
                if (bubbleMessage.docs.isNotEmpty) {
                  Map<String, dynamic> messageData =
                      bubbleMessage.docs.first.data()! as Map<String, dynamic>;

                  DocumentSnapshot userSnapshot =
                      await _db.getUser(messageData['sender']);
                  Map<String, dynamic> userData =
                      userSnapshot.data() as Map<String, dynamic>;
                  userData['uid'] = userSnapshot.id;
                  AppUser sender = AppUser.fromJSON(userData);
                  messageData['sender'] = sender;
                  Message message = Message.fromJSON(messageData);
                  messages.add(message);
                }
                //Return Chat Instance
                return Chat(
                  uid: d.id,
                  currentUserUid: _auth.appUser.uid,
                  members: members,
                  messages: messages,
                  activity: chatData["is_activity"],
                );
              },
            ).toList(),
          );
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
