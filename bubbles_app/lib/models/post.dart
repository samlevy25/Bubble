import 'package:bubbles_app/models/app_user.dart';
import 'package:bubbles_app/models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType {
  text,
  image,
  unknown,
}

class Post {
  final String uid;
  final AppUser sender;
  final PostType type;
  final String content;
  final DateTime sentTime;
  final String geoHash;
  final String LocationName;
  final List<Comment> comments;
  final List<String> voters;
  final int votesUp;
  final int votesDown;

  Post({
    required this.uid,
    required this.content,
    required this.type,
    required this.sender,
    required this.sentTime,
    required this.geoHash,
    required this.LocationName,
    required this.comments,
    required this.voters,
    required this.votesUp,
    required this.votesDown,
  });
  factory Post.fromJSON(Map<String, dynamic> jsonPost) {
    print("jsonData: $jsonPost");
    try {
      PostType postType;
      switch (jsonPost["type"]) {
        case "text":
          postType = PostType.text;
          break;
        case "image":
          postType = PostType.image;
          break;
        default:
          postType = PostType.unknown;
      }

      final List<dynamic> jsonVoters = jsonPost["voters"];
      final List<String> voters = List<String>.from(jsonVoters);

      return Post(
        uid: jsonPost["uid"],
        content: jsonPost["content"],
        type: postType,
        sender: jsonPost["sender"],
        sentTime: (jsonPost["sent_time"] as Timestamp).toDate(),
        geoHash: jsonPost["geoHash"],
        LocationName: jsonPost["LocationName"],
        comments: jsonPost["comments"] as List<Comment>,
        voters: voters,
        votesUp: jsonPost["votes_up"],
        votesDown: jsonPost["votes_down"],
      );
    } catch (e) {
      print('Error creating Post from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    String postType;
    switch (type) {
      case PostType.text:
        postType = "text";
        break;
      case PostType.image:
        postType = "image";
        break;
      default:
        postType = "";
    }
    return {
      "uid": uid, // Include uid in the JSON
      "content": content,
      "type": postType,
      "sender": sender.uid,
      "sent_time": Timestamp.fromDate(sentTime),
      "geoHash": geoHash,
      "LocationName": LocationName,
      "comments": comments,
      "voters": voters,
      "votes_up": votesUp,
      "votes_down": votesDown,
    };
  }
}
