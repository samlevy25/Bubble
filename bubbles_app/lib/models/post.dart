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
  List<Comment> comments;

  Post(
      {required this.content,
      required this.type,
      required this.senderID,
      required this.sentTime,
      required this.comments});

  factory Post.fromJSON(Map<String, dynamic> json) {
    PostType postType;
    switch (json["type"]) {
      case "text":
        postType = PostType.text;
        break;
      case "image":
        postType = PostType.image;
        break;
      default:
        postType = PostType.unkown;
    }

    List<Comment> comments = [];
    if (json["Comments"] != null) {
      for (var comment in json["Comments"]) {
        comments.add(
          Comment.fromJSON(comment),
        );
      }
    }

    return Post(
        content: json["content"],
        type: postType,
        senderID: json["sender_id"],
        sentTime: json["sent_time"].toDate(),
        comments: comments);
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
