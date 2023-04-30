import 'package:cloud_firestore/cloud_firestore.dart';

enum CommentType {
  text,
  image,
  unkown,
}

class Comment {
  final String senderID;
  final CommentType type;
  final String content;
  final DateTime sentTime;

  Comment(
      {required this.content,
      required this.type,
      required this.senderID,
      required this.sentTime});

  factory Comment.fromJSON(Map<String, dynamic> json) {
    CommentType postType;
    switch (json["type"]) {
      case "text":
        postType = CommentType.text;
        break;
      case "image":
        postType = CommentType.image;
        break;
      default:
        postType = CommentType.unkown;
    }
    return Comment(
      content: json["content"],
      type: postType,
      senderID: json["sender_id"],
      sentTime: json["sent_time"].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    String postType;
    switch (type) {
      case CommentType.text:
        postType = "text";
        break;
      case CommentType.image:
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
