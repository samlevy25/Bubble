import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'message.dart';

enum JoinMethod {
  gps,
  wifi,
  nfc,
}

class Bubble {
  final String currentUserUid;
  final String uid;
  final String name;
  final List<AppUser> members;
  final String image;
  final GeoPoint location;
  final String? wifi;
  final String? nfc;
  final List<Message> messages;
  final JoinMethod joinMethod;

  late final List<AppUser> _recepients;

  Bubble({
    required this.currentUserUid,
    required this.uid,
    required this.name,
    required this.members,
    required this.image,
    required this.location,
    required this.messages,
    required this.wifi,
    required this.nfc,
    required this.joinMethod,
  }) {
    _recepients = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<AppUser> recepients() {
    return _recepients;
  }

  String getName() {
    return name;
  }

  String getImageURL() {
    return image;
  }

  int getLenght() {
    return members.length;
  }

  List<double> getLocation() {
    return [location.latitude, location.longitude];
  }

  String getMethod() {
    switch (joinMethod) {
      case JoinMethod.wifi:
        return "wifi";
      case JoinMethod.nfc:
        return "nfc";
      default:
        return "gps";
    }
  }
}
