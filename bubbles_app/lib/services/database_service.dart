import 'package:bubbles_app/constants/bubble_key_types.dart';
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
      await _db.collection(userCollection).doc(uid).set(
        {
          "email": email,
          "image": imageURL,
          "last_active": DateTime.now().toUtc(),
          "username": username,
          "activities": [],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

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

  Future<void> updateUserActivities(
      String uid, List<Activity> activities) async {
    try {
      final userDoc = _db.collection(userCollection).doc(uid);

      // Convert the activities list to a JSON-compatible format
      final activitiesJson =
          activities.map((activity) => activity.toJson()).toList();

      await userDoc.update({
        'activities': FieldValue.arrayUnion(activitiesJson),
      });
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

  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      final userDoc = await _db.collection(userCollection).doc(uid).get();
      return userDoc;
    } catch (e) {
      print('Error getting user document: $e');
      rethrow;
    }
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

extension BubbleDatabaseService on DatabaseService {
  Future<List<Map<String, dynamic>>> getBubblesFormarks() async {
    final querySnapshot = await _db.collection(bubblesCollection).get();

    return querySnapshot.docs.map((doc) {
      final bubbleData = doc.data();
      return {
        "name": bubbleData['name'],
        "location": bubbleData['geohash'],
        "keyType": bubbleData['keyType'],
      };
    }).toList();
  }

  Stream<QuerySnapshot> getBubblesForUser(String? hash, String? bssid) {
    Stream<QuerySnapshot> bubbles =
        _db.collection(bubblesCollection).snapshots();

    if (hash != null) {
      bubbles = bubbles.where((snapshot) {
        return snapshot.docs.any((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String bubbleGeohash = data['geohash'];
          if (hash.startsWith(bubbleGeohash)) {
            if (data['keyType'] == BubbleKeyType.wifi.index) {
              String bubbleBssid = data['key'];
              return bubbleBssid == bssid;
            }
          }
          return false;
        });
      });
    }

    return bubbles;
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

  Stream<List<String>> streamParticipantsForBubble(String bubbleId) {
    return _db.collection('bubbles').doc(bubbleId).snapshots().map((snapshot) {
      List<String> participants = snapshot.data()!['memmbers'].cast<String>();
      return participants;
    });
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

  Future<void> addMembertoBubble(String bubbleID, String memberUid) async {
    try {
      await _db
          .collection(bubblesCollection)
          .doc(bubbleID)
          .update({
            'members': FieldValue.arrayUnion([memberUid])
          })
          .then((_) => print('Added'))
          .catchError((error) => print('Add failed: $error'));
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
    required int keyType,
    required String? key,
    required String geohash,
    String? description,
  }) async {
    try {
      await _db.collection(bubblesCollection).doc(bubbleUid).set(
        {
          "geohash": geohash,
          "admin": createrUid,
          "image": imageURL,
          "name": name,
          "description": description,
          "members": [createrUid],
          "keyType": keyType,
          "key": key,
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

extension ExplorerDatabaseService on DatabaseService {
  Stream<QuerySnapshot> streamPostsForExplorer() {
    return _db
        .collection(postsCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addPostToExplorer(Post message) async {
    try {
      await _db.collection(postsCollection).add(
            message.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
