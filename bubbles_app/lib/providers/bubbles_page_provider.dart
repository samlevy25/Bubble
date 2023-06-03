import 'dart:async';

//Packages
import 'package:bubbles_app/models/app_user.dart';
import 'package:bubbles_app/networks/gps.dart';
import 'package:bubbles_app/networks/wifi.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services

import '../constants/bubble_key_types.dart';
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
      _bubblesStream = _db.getBubblesForUser().listen((snapshot) async {
        bubbles = await Future.wait(snapshot.docs.map(
          (d) async {
            Map<String, dynamic> bubbleData = d.data() as Map<String, dynamic>;

            //Get Users In Bubble

            //Get Last Message For Bubble
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
            String name = bubbleData['name'];
            String image = bubbleData['image'];
            int keyTypeIndex = bubbleData['keyType'];
            String? methodValue = bubbleData['key'];
            String geohash = bubbleData['geohash'];
            GeoPoint? geoPoint = bubbleData['geoPoint'];
            String admin = bubbleData['admin'];
            String description = bubbleData['description'];
            int size = bubbleData["size"];

            //Return Bubble Instance
            print("Bubble: $name");
            return Bubble(
                uid: d.id,
                admin: admin,
                name: name,
                currentUserUid: _auth.appUser.uid,
                image: image,
                messages: messages,
                keyType: BubbleKeyType.getKeyTypeByIndex(index: keyTypeIndex),
                key: methodValue,
                geohash: geohash,
                geoPoint: geoPoint ?? const GeoPoint(0, 0),
                description: description,
                size: size);
          },
        ).toList());

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
