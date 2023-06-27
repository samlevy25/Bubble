// p
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

//s
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//w
import '../widgets/rounded_button.dart';

//pr
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService navigation;
  PlatformFile? _profileImage;
  final _registerFormKey = GlobalKey<FormState>();
  late ProgressDialog pr;

  // Email
  late bool checkEmail;
  late bool checkUsername;
  late String _email = '';
  Future<bool> checkEmailExists(String? email) async {
    final collection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot =
        await collection.where('email', isEqualTo: email).get();

    return querySnapshot.docs.isNotEmpty;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }

    RegExp regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!regExp.hasMatch(value)) {
      return "Invalid email. Use format: 'name@example.com'.";
    }

    if (checkEmail) {
      return "The Email is already used.";
    }

    return null;
  }

  // Username
  late String _username = '';
  Future<bool> checkUsernameExists(String? username) async {
    final collection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot =
        await collection.where('username', isEqualTo: username).get();

    return querySnapshot.docs.isNotEmpty;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a User name.';
    }

    RegExp regExp = RegExp(r"^[a-zA-Z].{7,}$");
    if (!regExp.hasMatch(value)) {
      return "Username: start with a letter, at least 8 characters long.";
    }

    if (checkUsername) {
      return "The Username is already used.";
    }

    return null;
  }

  //Paswword
  late String _password = '';
  late String _confirmPassword = '';
  bool isPasswordVisibleforPassword = true;
  bool isPasswordVisibleforConfirmPassword = true;
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    if (!regExp.hasMatch(value)) {
      return 'Password must be at least 6 characters long.';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter  password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    if (!regExp.hasMatch(value)) {
      return 'Confirm password must be at least 6 characters.';
    }

    if (_password != _confirmPassword) {
      return "Don't match with the password.";
    }

    return null;
  }

  //Photo
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    checkEmail = false;
    checkUsername = false;
    pr = ProgressDialog(context);
    pr.style(message: "Creating Profile...");

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sign up'),
        backgroundColor: Colors.lightBlue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceHeight * 0.03,
            vertical: _deviceHeight * 0.04,
          ),
          child: SingleChildScrollView(
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _profileImageField(),
                    SizedBox(
                      height: _deviceHeight * 0.04,
                    ),
                    _registerForm(),
                    SizedBox(
                      height: _deviceHeight * 0.08,
                    ),
                    _registerButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickedImageFromLibary().then(
              (file) => {
                setState(
                  () {
                    _profileImage = file;
                  },
                )
              },
            );
      },
      child: Column(
        children: [
          () {
            return _profileImage != null
                ? RoundedImageFile(
                    key: UniqueKey(),
                    image: _profileImage!,
                    size: _deviceHeight * 0.15,
                  )
                : RoundedImageNetwork(
                    key: UniqueKey(),
                    imagePath:
                        "https://firebasestorage.googleapis.com/v0/b/bubbles-96944.appspot.com/o/gui%2Fno_profile.jpeg?alt=media&token=a84c7e69-bb15-4f39-9279-ef031d19cd72",
                    size: _deviceHeight * 0.15,
                  );
          }(),
          SizedBox(height: _deviceHeight * 0.01),
          Visibility(
            visible: visible,
            child: Text(
              "Please select a profile's image.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[(700)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * 0.47,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
              validator: validateUsername,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person_2_outlined,
                  size: 18,
                  color: Colors.lightBlue,
                ),
                labelStyle: const TextStyle(
                  color: Colors.lightBlue,
                ),
                focusColor: Colors.lightBlue,
                filled: true,
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Username",
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
              validator: validateEmail,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  size: 18,
                  color: Colors.lightBlue,
                ),
                labelStyle: const TextStyle(
                  color: Colors.lightBlue,
                ),
                focusColor: Colors.lightBlue,
                filled: true,
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Email",
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              obscureText: isPasswordVisibleforPassword,
              validator: validatePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.lightBlue,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisibleforPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisibleforPassword =
                          !isPasswordVisibleforPassword;
                    });
                  },
                ),
                labelStyle: const TextStyle(
                  color: Colors.lightBlue,
                ),
                focusColor: Colors.lightBlue,
                filled: true,
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Password",
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
              obscureText: isPasswordVisibleforConfirmPassword,
              validator: validateConfirmPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.lightBlue,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisibleforConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisibleforConfirmPassword =
                          !isPasswordVisibleforConfirmPassword;
                    });
                  },
                ),
                labelStyle: const TextStyle(
                  color: Colors.lightBlue,
                ),
                focusColor: Colors.lightBlue,
                filled: true,
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Confirm password",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    visible = false;
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        checkEmail = false;
        checkUsername = false;

        if (_profileImage == null) {
          setState(() {
            visible = true;
          });
        }

        if (await checkEmailExists(_email)) {
          checkEmail = true;
        }

        if (await checkUsernameExists(_username)) {
          checkUsername = true;
        }

        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          await pr.show();
          _registerFormKey.currentState!.save();

          String? uid =
              await _auth.registerUserUsingEmailAndPassword(_email, _password);

          String? imageURL =
              await _cloudStorage.saveUserImageToStorage(uid!, _profileImage!);

          await _db.createUser(uid, _email, _username, imageURL!);

          _auth.logout();

          _auth.loginUsingEmailAndPassword(_email, _password);
          await pr.hide();
        }
      },
    );
  }
}
