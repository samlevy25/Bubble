import 'dart:async';

import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/constants/bubble_sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/message.dart';
import '../models/post.dart';

const String userCollection = "Users";
const String chatsCollection = "Chats";
const String bubblesCollection = "Bubbles";
const String messagesCollection = "Messages";
const String postsCollection = "Posts";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService();

  Future<void> createUser(
      String uid, String email, String username, String imageURL) async {
    try {
      DocumentReference userRef = _db.collection(userCollection).doc(uid);

      await userRef.set({
        "email": email,
        "image": imageURL,
        "last_active": DateTime.now().toUtc(),
        "username": username,
      });

      CollectionReference activitiesRef = userRef.collection('activities');

      // Create sample activities
      List<Activity> activities = [
        Activity('Account created', DateTime.now()),
      ];

      for (Activity activity in activities) {
        await activitiesRef.add(activity.toJson());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Update the username of a user document
  Future<void> updateUsername(
    String uid,
    newUsername,
  ) async {
    try {
      await _db
          .collection(userCollection)
          .doc(uid)
          .update({"username": newUsername});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Update the image URL of a user document
  Future<void> updateImageURL(
    String uid,
    imgUrl,
  ) async {
    try {
      await _db.collection(userCollection).doc(uid).update({"image": imgUrl});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addUserActivity(String uid, Activity activity) async {
    try {
      DocumentReference userRef = _db.collection('users').doc(uid);
      CollectionReference activitiesRef = userRef.collection('activities');

      await activitiesRef.add({
        "description": activity.description,
        "date": activity.date,
      });
    } catch (e) {
      print(e);
    }
  }

  // Retrieve chats for a specific user
  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return _db
        .collection(chatsCollection)
        .where('members', arrayContains: uid)
        .snapshots();
  }

// Get a single chat document that includes uid1 and uid2
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getChatForUser(
      String uid1, String uid2) async {
    final querySnapshot = await _db
        .collection(chatsCollection)
        .where('members', whereIn: [
          [uid1, uid2],
          [uid2, uid1]
        ])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }

    return null;
  }

  // Get the last message for a chat
  Future<QuerySnapshot> getLastMessageForChat(String chatID) {
    return _db
        .collection(chatsCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  // Stream chat messages for a specific chat
  Stream<QuerySnapshot> streamMessagesForChat(String chatID) {
    return _db
        .collection(chatsCollection)
        .doc(chatID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  // Update chat data for a specific chat
  Future<void> updateChatData(String chatID, Map<String, dynamic> data) async {
    try {
      await _db.collection(chatsCollection).doc(chatID).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Add a message to a chat
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

  // Get user document for a specific user ID
  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      final userDoc = await _db.collection(userCollection).doc(uid).get();
      return userDoc;
    } catch (e) {
      print('Error getting user document: $e');
      rethrow;
    }
  }

  // Get users with optional filtering by username
  Future<QuerySnapshot> getUsers({String? username}) {
    Query query = _db.collection(userCollection);
    if (username != null) {
      query = query
          .where("username", isGreaterThanOrEqualTo: username)
          .where("username", isLessThanOrEqualTo: "${username}z");
    }
    return query.get();
  }

  // Update the last seen time of a user
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

  // Delete a chat
  Future<void> deleteChat(String chatID) async {
    try {
      await _db.collection(chatsCollection).doc(chatID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> doesChatExistForUsers(String uid1, String uid2) async {
    final querySnapshot = await _db
        .collection(chatsCollection)
        .where('members', whereIn: [
          [uid1, uid2],
          [uid2, uid1]
        ])
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Create a chat document
  Future<DocumentReference?> createChat(Map<String, dynamic> data) async {
    try {
      DocumentReference chat = await _db.collection(chatsCollection).add(data);
      return chat;
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
    return null;
  }
}

// Extension methods for Bubble-related database operations
extension BubbleDatabaseService on DatabaseService {
  // Get bubbles for marks
  Future<List<Map<String, dynamic>>> getBubblesFormarks() async {
    final querySnapshot = await _db.collection(bubblesCollection).get();

    return querySnapshot.docs.map((doc) {
      final bubbleData = doc.data();
      return {
        "name": bubbleData['name'],
        "location": bubbleData['geohash'],
        "keyType": bubbleData['keyType'],
        "geoPoint": bubbleData['geopoint'],
        "size": bubbleData['size'],
      };
    }).toList();
  }

  // Stream bubbles for a user
  Stream<QuerySnapshot> getBubblesForUser() {
    return _db.collection(bubblesCollection).snapshots();
  }

  // Get the last message for a bubble
  Future<QuerySnapshot> getLastMessageForBubble(String bubbleID) {
    return _db
        .collection(bubblesCollection)
        .doc(bubbleID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  // Stream messages for a specific bubble
  Stream<QuerySnapshot> streamMessagesForBubble(String bubbleID) {
    return _db
        .collection(bubblesCollection)
        .doc(bubbleID)
        .collection(messagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  // Update bubble data
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

  // Add a message to a bubble
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

  // Delete a bubble document
  Future<void> deleteBubble(String bubbleID) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Create a new bubble
  Future<void> createBubble({
    required String bubbleUid,
    required String createrUid,
    required String name,
    required String imageURL,
    required int keyType,
    required String? key,
    required String geohash,
    required GeoPoint geoPoint,
    required int bubbleSize,
    String? description,
  }) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleUid).set(
        {
          "geohash": geohash,
          "geopoint": geoPoint,
          "admin": createrUid,
          "image": imageURL,
          "name": name,
          "description": description,
          "keyType": keyType,
          "key": key,
          "size": bubbleSize,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Generate a unique identifier for a new bubble
  String generateBubbleUid() {
    return _db.collection(bubblesCollection).doc().id;
  }

  // Update the name of a bubble document
  Future<void> updateBubblename(
    String uid,
    String newNameBubble,
  ) async {
    try {
      await _db
          .collection(bubblesCollection)
          .doc(uid)
          .update({"name": newNameBubble});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Update the description of a bubble document
  Future<void> updateBubbleDescription(
    String uid,
    String newDescriptionBubble,
  ) async {
    try {
      await _db
          .collection(bubblesCollection)
          .doc(uid)
          .update({"name": newDescriptionBubble});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

// Extension for Explorer-related database operations
extension ExplorerDatabaseService on DatabaseService {
  // Stream posts for the Explorer feature
  Stream<QuerySnapshot> streamPostsForExplorer() {
    return _db
        .collection(postsCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addPostToExplorer(Post post) async {
    try {
      await _db.collection(postsCollection).add(
            post.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
