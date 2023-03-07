import 'package:bubbles_app/networks/gps.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'message.dart';

enum JoinMethod {
  gps,
  wifi,
  nfc,
}

class Bubble {
  final String currentUserUid;
  final String uid;
  final String name;
  final List<AppUser> members;
  final String image;
  final List<Message> messages;

  final int keyType;
  final String? key;
  final String geohash;

  late final List<AppUser> _recepients;

  Bubble({
    required this.currentUserUid,
    required this.uid,
    required this.name,
    required this.members,
    required this.image,
    required this.messages,
    required this.keyType,
    required this.key,
    required this.geohash,
  }) {
    _recepients = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<AppUser> recepients() {
    return _recepients;
  }

  String getName() {
    return name;
  }

  String getImageURL() {
    return image;
  }

  int getLenght() {
    return members.length;
  }

  String getGeohash() {
    return geohash;
  }

  int getMethod() {
    return keyType;
  }

  String? getMethodValue() {
    return key;
  }

  Future<bool> joinMemmber(AppUser user) async {
    String userLocation = await getCurrentGeoHash(10);
    if (members.contains(user)) {
      if (kDebugMode) {
        print("Already In");
      }
      return true;
    }

    if (geohash.startsWith(userLocation)) {
      members.add(user);
      if (kDebugMode) {
        print("Joined");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("not allowed to join");
      }
      return false;
    }
  }
}
