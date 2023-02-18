//Packages
import 'package:flutter/material.dart';
import 'dart:async';

//Services

//Providers

//Models
import '../models/chat.dart';

class ChatsPageProvider extends ChangeNotifier {
  List<Chat>? chats;

  late StreamSubscription _chatsStream;

  ChatsPageProvider();

  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {}
}
