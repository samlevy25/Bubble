import 'dart:async';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/message.dart';

class BubblePageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  final AuthenticationProvider _auth;
  final ScrollController _messagesListViewController;

  final String _bubbleId;
  List<Message>? messages;

  late StreamSubscription _messagesStream;

  String? _message;

  set message(String value) {
    _message = value;
  }

  BubblePageProvider(
      this._bubbleId, this._auth, this._messagesListViewController) {
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

  void goBack() {
    _navigation.goBack();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForBubble(_bubbleId).listen(
        (snapshot) {
          List<Message> snapMessages = snapshot.docs.map(
            (m) {
              Map<String, dynamic> messageData =
                  m.data() as Map<String, dynamic>;
              return Message.fromJSON(messageData);
            },
          ).toList();
          messages = snapMessages;
          notifyListeners();
          WidgetsBinding.instance.addPostFrameCallback(
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

  void listenToKeyboardChanges() {}

  void sendTextMessage() {
    if (_message != null) {
      Message messageToSend = Message(
        content: _message!,
        type: MessageType.text,
        senderID: _auth.appUser.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToBubble(_bubbleId, messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? file = await _media.pickedImageFromLibary();
      if (file != null) {
        String? downloadURL = await _storage.saveSentBubbleImageToStorage(
            _bubbleId, _auth.appUser.uid, file);
        Message messageToSend = Message(
          content: downloadURL!,
          type: MessageType.image,
          senderID: _auth.appUser.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToBubble(_bubbleId, messageToSend);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending image message.");
        print(e);
      }
    }
  }

  void deleteBubble() {
    goBack();
    _db.deleteBubble(_bubbleId);
  }
}
