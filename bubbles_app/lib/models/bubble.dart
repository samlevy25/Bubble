
import '../models/app_user.dart';
import 'message.dart';

class Bubble {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<AppUser> members;
  List<Message> messages;

  late final List<AppUser> _recepients;

  Bubble({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  }) {
    _recepients = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<AppUser> recepients() {
    return _recepients;
  }

  String title() {
    return !group
        ? _recepients.first.username
        : _recepients.map((user) => user.username).join(", ");
  }

  String imageURL() {
    return !group
        ? _recepients.first.imageURL
        : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
  }
}
