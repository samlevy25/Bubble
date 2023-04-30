import 'dart:async';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//Services
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models

class ExplorerPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  final AuthenticationProvider _auth;
  final ScrollController _postsListViewController;

  List<Post>? posts;

  late StreamSubscription _postsStream;

  String? post;

  ExplorerPageProvider(this._auth, this._postsListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    listenToPosts();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _postsStream.cancel();
    super.dispose();
  }

  void listenToPosts() {
    try {
      _postsStream = _db.streamPostsForExplorer().listen(
        (snapshot) {
          List<Post> snapPosts = snapshot.docs.map(
            (m) {
              Map<String, dynamic> postData = m.data() as Map<String, dynamic>;
              return Post.fromJSON(postData);
            },
          ).toList();
          posts = snapPosts;
          notifyListeners();
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (_postsListViewController.hasClients) {
                _postsListViewController
                    .jumpTo(_postsListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting posts.");
        print(e);
      }
    }
  }

  void listenToKeyboardChanges() {}

  void sendTextPost() {
    if (post != null) {
      Post postToSend = Post(
          content: post!,
          type: PostType.text,
          senderID: _auth.appUser.uid,
          sentTime: DateTime.now(),
          comments: []);
      _db.addPostToExplorer(postToSend);
    }
  }

  void sendImagePost() async {
    try {
      PlatformFile? file = await _media.pickedImageFromLibary();
      if (file != null) {
        String? downloadURL =
            await _storage.saveExplorerImageToStorage(_auth.appUser.uid, file);
        Post postToSend = Post(
            content: downloadURL!,
            type: PostType.image,
            senderID: _auth.appUser.uid,
            sentTime: DateTime.now(),
            comments: []);
        _db.addPostToExplorer(postToSend);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending image post.");
        print(e);
      }
    }
  }

  void goBack() {
    _navigation.goBack();
  }
}
