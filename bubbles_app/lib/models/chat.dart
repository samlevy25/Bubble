import 'app_user.dart';
import 'message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;

  final List<AppUser> members;
  List<Message> messages;

  late final List<AppUser> _recepient;

  Chat({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
  }) {
    _recepient = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<AppUser> recepients() {
    return _recepient;
  }

  String title() {
    return _recepient.first.username;
  }

  String imageURL() {
    return _recepient.first.imageURL;
  }
}
