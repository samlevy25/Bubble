import 'package:bubbles_app/models/bubble.dart';
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

  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(chatsCollection)
        .doc(_chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> updateChatData(String chatID, Map<String, dynamic> _data) async {
    try {
      await _db.collection(chatsCollection).doc(chatID).update(_data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addMessageToChat(String _chatID, Message _message) async {
    try {
      await _db
          .collection(chatsCollection)
          .doc(_chatID)
          .collection(messagesCollection)
          .add(
            _message.toJson(),
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
    Query _query = _db.collection(userCollection);
    if (username != null) {
      _query = _query
          .where("username", isGreaterThanOrEqualTo: username)
          .where("username", isLessThanOrEqualTo: username + "z");
    }
    return _query.get();
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

  Future<void> deleteChat(String _chatID) async {
    try {
      await _db.collection(chatsCollection).doc(_chatID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat =
          await _db.collection(chatsCollection).add(_data);
      return _chat;
    } catch (e) {
      print(e);
    }
  }
}

//exs
//e
//e

extension x on DatabaseService {
  Stream<QuerySnapshot> getBubblesForUser(String uid) {
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

  Stream<QuerySnapshot> streamMessagesForBubble(String _bubbleID) {
    return _db
        .collection(bubblesCollection)
        .doc(_bubbleID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> updateBubbleData(
      String bubbleID, Map<String, dynamic> _data) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleID).update(_data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addMessageToBubble(String _bubbleID, Message _message) async {
    try {
      await _db
          .collection(bubblesCollection)
          .doc(_bubbleID)
          .collection(messagesCollection)
          .add(
            _message.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteBubble(String _bubbleID) async {
    try {
      await _db.collection(bubblesCollection).doc(_bubbleID).delete();
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
    required GeoPoint location,
  }) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleUid).set(
        {
          "location": location,
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
