import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'message.dart';

class Bubble {
  final String currentUserUid;
  final String uid;
  final String name;
  final List<AppUser> members;
  final String image;
  final GeoPoint geoPoint;
  List<Message> messages;

  late final List<AppUser> _recepients;

  Bubble({
    required this.currentUserUid,
    required this.uid,
    required this.name,
    required this.members,
    required this.image,
    required this.geoPoint,
    required this.messages,
  }) {
    _recepients = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<AppUser> recepients() {
    return _recepients;
  }

  String title() {
    return name;
  }

  String imageURL() {
    return image;
  }

  int numberOfMemmbers() {
    return members.length;
  }

  List<double> location() {
    return [geoPoint.latitude, geoPoint.longitude];
  }
}
