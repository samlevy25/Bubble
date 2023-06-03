import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/networks/gps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'app_user.dart';
import '../services/database_service.dart';
import 'message.dart';

enum JoinMethod {
  gps,
  wifi,
  nfc,
}

class Bubble {
  final String currentUserUid;
  final String uid;
  String name;
  final String description; // Added description property

  final String image;
  final List<Message> messages;

  final BubbleKeyType keyType;
  final String? key;

  final int size;

  final String geohash;
  final GeoPoint geoPoint;
  final String admin;

  final DatabaseService _db = GetIt.instance.get<DatabaseService>();

  Bubble({
    required this.currentUserUid,
    required this.admin,
    required this.uid,
    required this.name,
    required this.description, // Added description parameter

    required this.image,
    required this.messages,
    required this.keyType,
    required this.key,
    required this.geohash,
    required this.geoPoint,
    required this.size,
  }) {}

  // Returns the list of recipients excluding the current user

  // Returns the name of the bubble
  String getName() {
    return name;
  }

  // Returns the image URL of the bubble
  String getImageURL() {
    return image;
  }

  // Returns the number of members in the bubble

  // Returns the geohash of the bubble
  String getGeohash() {
    return geohash;
  }

  // Returns the join method type of the bubble
  BubbleKeyType getMethod() {
    return keyType;
  }

  // Returns the join method value of the bubble
  String? getMethodValue() {
    return key;
  }

  String getDescription() {
    return description;
  }

  void deleteBubble() {
    _db.deleteBubble(uid);
  }

  void updateBubbleName(String newName) {
    _db.updateBubblename(uid, newName);
  }

  void updateBubbleDescription(String newDescription) {
    _db.updateBubbleDescription(uid, newDescription);
  }
}
