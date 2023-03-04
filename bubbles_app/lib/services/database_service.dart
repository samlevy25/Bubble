import 'package:bubbles_app/models/geohash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/message.dart';

const String userCollection = "Users";
const String chatsCollection = "Chats";
const String bubblesCollection = "Bubbles";
const String messagesCollection = "Messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService();

  Future<void> createUser(
      String uid, String email, String username, String imageURL) async {
    try {
      await _db.collection(userCollection).doc(uid).set(
        {
          "email": email,
          "image": imageURL,
          "last_active": DateTime.now().toUtc(),
          "username": username,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return _db
        .collection(chatsCollection)
        .where('members', arrayContains: uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String chatID) {
    return _db
        .collection(chatsCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String chatID) {
    return _db
        .collection(chatsCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> updateChatData(String chatID, Map<String, dynamic> data) async {
    try {
      await _db.collection(chatsCollection).doc(chatID).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addMessageToChat(String chatID, Message message) async {
    try {
      await _db
          .collection(chatsCollection)
          .doc(chatID)
          .collection(messagesCollection)
          .add(
            message.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection(userCollection).doc(uid).get();
  }

  Future<QuerySnapshot> getUsers({String? username}) {
    Query query = _db.collection(userCollection);
    if (username != null) {
      query = query
          .where("username", isGreaterThanOrEqualTo: username)
          .where("username", isLessThanOrEqualTo: "${username}z");
    }
    return query.get();
  }

  Future<void> updateUserLastSeenTime(String uid) async {
    try {
      await _db.collection(userCollection).doc(uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteChat(String chatID) async {
    try {
      await _db.collection(chatsCollection).doc(chatID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> data) async {
    try {
      DocumentReference chat = await _db.collection(chatsCollection).add(data);
      return chat;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}

//exs
//e
//e

extension DatabaseServiceExtension on DatabaseService {
  Stream<QuerySnapshot> getBubblesForUser(String uid, GeoHash geoPoint) {
    return _db
        .collection(bubblesCollection)
        .where('members', arrayContains: uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForBubble(String bubbleID) {
    return _db
        .collection(bubblesCollection)
        .doc(bubbleID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForBubble(String bubbleID) {
    return _db
        .collection(bubblesCollection)
        .doc(bubbleID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> updateBubbleData(
      String bubbleID, Map<String, dynamic> data) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleID).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addMessageToBubble(String bubbleID, Message message) async {
    try {
      await _db
          .collection(bubblesCollection)
          .doc(bubbleID)
          .collection(messagesCollection)
          .add(
            message.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteBubble(String bubbleID) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> createBubble({
    required String bubbleUid,
    required String createrUid,
    required String name,
    required String imageURL,
    required int methoudType,
    required String? methodValue,
    required GeoHash location,
  }) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleUid).set(
        {
          "location": location.hash,
          "image": imageURL,
          "name": name,
          "members": [createrUid],
          "methodType": methoudType,
          "methodValue": methodValue,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String generateBubbleUid() {
    return _db.collection(bubblesCollection).doc().id;
  }
}
