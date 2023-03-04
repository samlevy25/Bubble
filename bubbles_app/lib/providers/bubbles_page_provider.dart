import 'dart:async';

//Packages
import 'package:bubbles_app/models/app_user.dart';
import 'package:bubbles_app/networks/gps.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../models/geohash.dart';
import '../services/database_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/bubble.dart';
import '../models/message.dart';

class BubblesPageProvider extends ChangeNotifier {
  final AuthenticationProvider _auth;

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
      _bubblesStream = _db
          .getBubblesForUser(_auth.appUser.uid, await determinePosition(22))
          .listen((snapshot) async {
        bubbles = await Future.wait(
          snapshot.docs.map(
            (d) async {
              Map<String, dynamic> bubbleData =
                  d.data() as Map<String, dynamic>;

              //Get Users In Bubble
              List<AppUser> members = [];
              for (var mUid in bubbleData["members"]) {
                DocumentSnapshot userSnapshot = await _db.getUser(mUid);
                Map<String, dynamic> userData =
                    userSnapshot.data() as Map<String, dynamic>;
                userData["uid"] = userSnapshot.id;
                members.add(
                  AppUser.fromJSON(userData),
                );
              }
              //Get Last Message For Bubble
              List<Message> messages = [];
              QuerySnapshot bubbleMessage =
                  await _db.getLastMessageForBubble(d.id);
              if (bubbleMessage.docs.isNotEmpty) {
                Map<String, dynamic> messageData =
                    bubbleMessage.docs.first.data()! as Map<String, dynamic>;
                Message message = Message.fromJSON(messageData);
                messages.add(message);
              }
              String name = bubbleData['name'];
              String image = bubbleData['image'];
              int methodType = bubbleData['methodType'];
              String? methodValue = bubbleData['methodValue'];
              GeoHash location = GeoHash.fromHash(bubbleData['location']);

              //Return Bubble Instance
              return Bubble(
                uid: d.id,
                name: name,
                currentUserUid: _auth.appUser.uid,
                members: members,
                image: image,
                messages: messages,
                methodType: methodType,
                methodValue: methodValue,
                geoHash: location,
              );
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting bubbles.");
        print(e);
      }
    }
  }
}
