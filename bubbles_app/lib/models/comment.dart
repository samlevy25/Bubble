import 'package:cloud_firestore/cloud_firestore.dart';

enum CommentType {
  text,
  image,
  unknown,
}

class Comment {
  final String uid;
  final String senderID;
  final CommentType type;
  final String content;
  final DateTime sentTime;
  List<String> voters;
  int votesUp;
  int votesDown;

  Comment({
    required this.uid,
    required this.content,
    required this.type,
    required this.senderID,
    required this.sentTime,
    required this.voters,
    this.votesUp = 0,
    this.votesDown = 0,
  });

  factory Comment.fromJSON(Map<String, dynamic> json) {
    CommentType commentType;
    switch (json["type"]) {
      case "text":
        commentType = CommentType.text;
        break;
      case "image":
        commentType = CommentType.image;
        break;
      default:
        commentType = CommentType.unknown;
    }
    return Comment(
      uid: json["uid"],
      content: json["content"],
      type: commentType,
      senderID: json["sender_id"],
      sentTime: (json["sent_time"] as Timestamp).toDate(),
      voters: List<String>.from(json["voters"] ?? []),
      votesUp: json["votes_up"] ?? 0,
      votesDown: json["votes_down"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    String commentType;
    switch (type) {
      case CommentType.text:
        commentType = "text";
        break;
      case CommentType.image:
        commentType = "image";
        break;
      default:
        commentType = "";
    }
    return {
      "uid": uid,
      "content": content,
      "type": commentType,
      "sender_id": senderID,
      "sent_time": Timestamp.fromDate(sentTime),
      "voters": voters,
      "votes_up": votesUp,
      "votes_down": votesDown,
    };
  }
}
