import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

const String userCollection = "Users";
const String chatsCollection = "Chats";
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

  Future<void> addMessageToChat(String _chatID, ChatMessage _message) async {
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
}
