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
  final List<Message> messages;

  final int methodType;
  final String? methodValue;
  final GeoPoint location;

  late final List<AppUser> _recepients;

  Bubble({
    required this.currentUserUid,
    required this.uid,
    required this.name,
    required this.members,
    required this.image,
    required this.messages,
    required this.methodType,
    required this.methodValue,
    required this.location,
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

  int getMethod() {
    return methodType;
  }

  String? getMethodValue() {
    return methodValue;
  }
}
