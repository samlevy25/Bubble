import 'dart:async';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

//Services
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  String _chatId;
  List<ChatMessage>? messages;

  late StreamSubscription _messagesStream;
  //late StreamSubscription _keyboardVisibilityStream;
  //late KeyboardVisibilityController _keyboardVisibilityController;

  String? _message;

  String get message {
    return message;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    //_keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessages();
    //listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    super.dispose();
  }

  void goBack() {
    _navigation.goBack();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
        (_snapshot) {
          List<ChatMessage> _messages = _snapshot.docs.map(
            (_m) {
              Map<String, dynamic> _messageData =
                  _m.data() as Map<String, dynamic>;
              return ChatMessage.fromJSON(_messageData);
            },
          ).toList();
          messages = _messages;
          notifyListeners();
          WidgetsBinding.instance!.addPostFrameCallback(
            (_) {
              if (_messagesListViewController.hasClients) {
                _messagesListViewController.jumpTo(
                    _messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting messages.");
        print(e);
      }
    }
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.text,
        senderID: _auth.appUser.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? file = await _media.pickedImageFromLibary();
      if (file != null) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.appUser.uid, file);
        ChatMessage messageToSend = ChatMessage(
          content: downloadURL!,
          type: MessageType.image,
          senderID: _auth.appUser.uid,
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
}
