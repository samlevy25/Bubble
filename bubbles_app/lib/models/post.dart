import 'package:bubbles_app/models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType {
  text,
  image,
  unkown,
}

class Post {
  final String senderID;
  final PostType type;
  final String content;
  final DateTime sentTime;
  final GeoPoint geoPoint;
  List<Comment> comments;

  Post(
      {required this.content,
      required this.type,
      required this.senderID,
      required this.sentTime,
      required this.comments,
      required this.geoPoint});

  factory Post.fromJSON(Map<String, dynamic> jsonPost) {
    PostType postType;
    switch (jsonPost["type"]) {
      case "text":
        postType = PostType.text;
        break;
      case "image":
        postType = PostType.image;
        break;
      default:
        postType = PostType.unkown;
    }

    return Post(
        content: jsonPost["content"],
        type: postType,
        senderID: jsonPost["sender_id"],
        sentTime: jsonPost["sent_time"].toDate(),
        comments: jsonPost["comments"],
        geoPoint: jsonPost["geopoint"]);
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
      "content": content,
      "type": postType,
      "sender_id": senderID,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}
