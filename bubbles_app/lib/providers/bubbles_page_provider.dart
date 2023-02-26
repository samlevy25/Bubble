import 'dart:async';

//Packages
import 'package:bubbles_app/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../services/database_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/bubble.dart';
import '../models/message.dart';

class BubblesPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Bubble>? bubbles;

  late StreamSubscription _bubblesStream;

  BubblesPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getBubble();
  }

  @override
  void dispose() {
    _bubblesStream.cancel();
    super.dispose();
  }

  // need some changes
  void getBubble() async {
    try {
      _bubblesStream =
          _db.getBubblesForUser(_auth.appUser.uid).listen((_snapshot) async {
        bubbles = await Future.wait(
          _snapshot.docs.map(
            (_d) async {
              Map<String, dynamic> _bubbleData =
                  _d.data() as Map<String, dynamic>;
              //Get Users In Chat
              List<AppUser> _members = [];
              for (var _uid in _bubbleData["members"]) {
                DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData["uid"] = _userSnapshot.id;
                _members.add(
                  AppUser.fromJSON(_userData),
                );
              }
              //Get Last Message For Chat
              List<Message> _messages = [];
              QuerySnapshot _bubbleMessage =
                  await _db.getLastMessageForBubble(_d.id);
              if (_bubbleMessage.docs.isNotEmpty) {
                Map<String, dynamic> _messageData =
                    _bubbleMessage.docs.first.data()! as Map<String, dynamic>;
                Message _message = Message.fromJSON(_messageData);
                _messages.add(_message);
              }
              //Return Chat Instance
              return Bubble(
                uid: _d.id,
                currentUserUid: _auth.appUser.uid,
                members: _members,
                messages: _messages,
                activity: _bubbleData["is_activity"],
                group: _bubbleData["is_group"],
              );
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      print("Error getting bubbles.");
      print(e);
    }
  }
}
