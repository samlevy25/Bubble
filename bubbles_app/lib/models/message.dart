import 'package:bubbles_app/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  unkown,
}

class Message {
  final AppUser sender;
  final MessageType type;
  String content;
  final DateTime sentTime;

  Message(
      {required this.content,
      required this.type,
      required this.sender,
      required this.sentTime});

  factory Message.fromJSON(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json["type"]) {
      case "text":
        messageType = MessageType.text;
        break;
      case "image":
        messageType = MessageType.image;
        break;
      default:
        messageType = MessageType.unkown;
    }
    return Message(
      content: json["content"],
      type: messageType,
      sender: json["sender"],
      sentTime: json["sent_time"].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    String messageType;
    switch (type) {
      case MessageType.text:
        messageType = "text";
        break;
      case MessageType.image:
        messageType = "image";
        break;
      default:
        messageType = "";
    }
    return {
      "content": content,
      "type": messageType,
      "sender_id": sender.uid,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}
