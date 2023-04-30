//p

import 'package:bubbles_app/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get_it/get_it.dart';

//services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late AppUser appUser;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _databaseService.updateUserLastSeenTime(user.uid);
        _databaseService.getUser(user.uid).then(
          (snapshot) {
            Map<String, dynamic> userData =
                snapshot.data()! as Map<String, dynamic>;
            appUser = AppUser.fromJSON(
              {
                "uid": user.uid,
                "username": userData["username"],
                "email": userData["email"],
                "last_active": userData["last_active"],
                "image": userData["image"],
              },
            );
            _navigationService.removeAndNavigateToRoute('/home');
          },
        );
      } else {
        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  Future<void> loginUsingEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      if (kDebugMode) {
        print("Error logging user into Firebase");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user!.uid;
    } on FirebaseAuthException {
      if (kDebugMode) {
        print("Error: create user");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> changeEmail(newEmail, currentPassword) async {
    try {
      UserCredential? authResult =
          await _auth.currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: _auth.currentUser!.email!,
          password: currentPassword,
        ),
      );
      await authResult?.user?.updateEmail(newEmail);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> changePassword(newPassword, currrentPassword) async {
    try {
      UserCredential? authResult =
          await _auth.currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: _auth.currentUser!.email!,
          password: currrentPassword,
        ),
      );
      await authResult?.user?.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
