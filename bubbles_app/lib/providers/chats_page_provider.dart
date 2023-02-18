//Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

//Services
import '../services/database_service.dart';

//Providers
import 'authentication_provider.dart';

//Models
import '../models/chat.dart';

class ChatsPageProvider extends ChangeNotifier {
  final AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;

  late StreamSubscription _chatsStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
  }

  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {}
}
