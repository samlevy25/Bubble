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

  Post(
      {required this.content,
      required this.type,
      required this.senderID,
      required this.sentTime});

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
    return Post(
      content: json["content"],
      type: postType,
      senderID: json["sender_id"],
      sentTime: json["sent_time"].toDate(),
    );
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
