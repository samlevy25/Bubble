import 'dart:async';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

//Services
import '../models/app_user.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/loger.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/message.dart';

import 'package:translator/translator.dart';

class BubblePageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;
  late Logger _logger;

  final AuthenticationProvider _auth;
  final ScrollController _messagesListViewController;

  final String _bubbleId;
  List<Message>? messages;
  List<AppUser> memmbers = [];
  late StreamSubscription _messagesStream;

  String? _message;

  final translator = GoogleTranslator();

  set message(String value) {
    _message = value;
  }

  BubblePageProvider(
      this._bubbleId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _logger = GetIt.instance.get<LoggerService>().logger;

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
    _messagesStream = _db.streamMessagesForBubble(_bubbleId).listen(
      (snapshot) async {
        List<Message> snapMessages = await Future.wait(snapshot.docs.map(
          (m) async {
            Map<String, dynamic> messageData = m.data() as Map<String, dynamic>;
            DocumentSnapshot userSnapshot =
                await _db.getUser(messageData['sender']);
            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;
            userData['uid'] = userSnapshot.id;
            AppUser sender = AppUser.fromJSON(userData);
            messageData['sender'] = sender;
            return Message.fromJSON(messageData);
          },
        ).toList());

        messages = snapMessages;

        for (Message message in messages!) {
          if (message.type == MessageType.text) {
            message.content = await translateMsg(message.content);
          }
        }

        notifyListeners();

        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_messagesListViewController.hasClients) {
            _messagesListViewController
                .jumpTo(_messagesListViewController.position.maxScrollExtent);
          }
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print("Error getting messages.");
          print(error);
        }
      },
    );
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
          sender: _auth.appUser,
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

  Future<String> translateMsg(String msg) async {
    Translation translated = await msg.translate(to: 'fr');
    return translated.toString();
  }
}
