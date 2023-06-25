import 'dart:async';

import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/constants/bubble_sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/app_user.dart';
import '../models/comment.dart';
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

  // Update the email of a user document
  Future<void> updateEmail(
    String uid,
    newEmail,
  ) async {
    try {
      await _db.collection(userCollection).doc(uid).update({"email": newEmail});
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
      print('Fetching user document for UID: $uid');
      final userDoc = await _db.collection(userCollection).doc(uid).get();
      print('User document fetched successfully');
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
  Future<Post?> getPost(String postUid) async {
    print("UID: $postUid");
    try {
      final postSnapshot =
          await _db.collection(postsCollection).doc(postUid).get();
      print("Post snapshot: $postSnapshot");

      if (postSnapshot.exists) {
        final postData = postSnapshot.data();
        print("Post data: $postData");

        final senderUid = postData?["sender"];
        if (senderUid != null && senderUid is String) {
          final userDoc = await getUser(senderUid);
          print("User document: $userDoc");

          if (userDoc.exists) {
            final senderData = userDoc.data() as Map<String, dynamic>;
            senderData["uid"] = userDoc.id;
            print("Sender data: $senderData");

            final AppUser sender = AppUser.fromJSON(senderData);
            print("Sender object: $sender");

            postData?["sender"] = sender;

            final commentsCollection =
                postSnapshot.reference.collection('comments');
            final commentsQuerySnapshot = await commentsCollection.get();
            final List<Comment> comments = [];

            for (final commentDoc in commentsQuerySnapshot.docs) {
              final commentData = commentDoc.data();
              // Assuming Comment.fromJSON is a factory method in Comment class to create Comment object
              final comment = Comment.fromJSON(commentData);
              comments.add(comment);
            }

            postData?["comments"] = comments;

            return Post.fromJSON(postData!);
          } else {
            print("Sender document not found");
          }
        } else {
          print("Invalid or missing sender UID");
        }
      } else {
        print("Post not found");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Stream posts for the Explorer feature
  Stream<QuerySnapshot> streamPostsForExplorer() {
    return _db
        .collection(postsCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addPostToExplorer(Post post, String uid) async {
    try {
      await _db.collection(postsCollection).doc(uid).set(
            post.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addVoteToPost(
      String postID, String userID, int voteValue) async {
    try {
      print(postID);
      final postRef = _db.collection(postsCollection).doc(postID);
      final postSnapshot = await postRef.get();

      print("postSnapshot.exists: ${postSnapshot.exists}");

      if (postSnapshot.exists) {
        final postVoters =
            List<String>.from(postSnapshot.data()?['voters'] ?? []);
        final votesUp = postSnapshot.data()?['votes_up'] ?? 0;
        final votesDown = postSnapshot.data()?['votes_down'] ?? 0;

        print("postVoters: $postVoters");
        print("votesUp: $votesUp");
        print("votesDown: $votesDown");

        if (!postVoters.contains(userID)) {
          postVoters.add(userID);

          if (voteValue > 0) {
            await postRef.update({
              'voters': postVoters,
              'votes_up': votesUp + 1,
            });
            print("Vote added: votes_up increased by 1");
          } else if (voteValue < 0) {
            await postRef.update({
              'voters': postVoters,
              'votes_down': votesDown + 1,
            });
            print("Vote added: votes_down increased by 1");
          }
        } else {
          print("User has already voted");
        }
      } else {
        print("Post not found");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String generatePostUid() {
    return _db.collection('postsCollection').doc().id;
  }

  Future<void> addCommentToPost(String postID, Comment comment) async {
    try {
      final postRef = _db.collection(postsCollection).doc(postID);

      await postRef.collection('comments').add(
            comment.toJson(),
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
