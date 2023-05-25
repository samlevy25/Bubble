import 'dart:async';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//Services
import '../models/app_user.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  final AuthenticationProvider _auth;
  final ScrollController _messagesListViewController;

  final String _chatId;
  List<Message>? messages;

  late StreamSubscription _messagesStream;

  String? _message;

  set message(String value) {
    _message = value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    _messagesStream =
        _db.streamMessagesForChat(_chatId).listen((snapshot) async {
      List<Message> snapshotMessages = await Future.wait(snapshot.docs.map(
        (m) async {
          Map<String, dynamic> messageData = m.data() as Map<String, dynamic>;
          DocumentSnapshot userSnapshot =
              await _db.getUser(messageData['senderId']);
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          userData["uid"] = userSnapshot.id;

          messageData['sender'] = AppUser.fromJSON(userData);

          return Message.fromJSON(messageData);
        },
      ).toList());

      messages = snapshotMessages;
      notifyListeners();

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (_messagesListViewController.hasClients) {
          _messagesListViewController
              .jumpTo(_messagesListViewController.position.maxScrollExtent);
        }
      });
    }, onError: (error) {
      if (kDebugMode) {
        print("Error getting messages.");
        print(error);
      }
    });
  }

  void listenToKeyboardChanges() {}

  void sendTextMessage() {
    if (_message != null) {
      Message messageToSend = Message(
        content: _message!,
        type: MessageType.text,
        sender: _auth.appUser,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? file = await _media.pickedImageFromLibary();
      if (file != null) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.appUser.uid, file);
        Message messageToSend = Message(
          content: downloadURL!,
          type: MessageType.image,
          sender: _auth.appUser,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, messageToSend);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending image message.");
        print(e);
      }
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
