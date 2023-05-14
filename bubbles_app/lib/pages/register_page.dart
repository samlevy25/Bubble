// p
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//s
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//w
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '/widgets/CustomTextField_widget.dart';
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
  late bool checkEmail;
  late bool checkUsername;
  late String? _email;
  late String? _username;

  String? _password;
  String? _confirmPassword;
  PlatformFile? _profileImage;
  final _registerFormKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }

    RegExp regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }

    if (checkEmail) {
      return "The Email is already used.";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid password.';
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

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a User name.';
    }

    RegExp regExp = RegExp(r".{8,}");
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid User name.';
    }
    print(checkUsername);
    if (checkUsername) {
      return "The Username is already used.";
    }

    return null;
  }

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
    _email = "";
    _username = "";

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: const Color.fromARGB(255, 21, 0, 255),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceHeight * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.80,
        width: _deviceWidth * 0.97,
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageField(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerButton(),
            ],
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
      child: () {
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
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * 0.40,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFieldWidget(
              onSaved: (value) {
                setState(() {
                  _username = value;
                });
              },
              onChanged: (value) => _username = value,
              regEx: r'.{8,}',
              hintText: 'Username',
              validator: validateUsername,
              obscureText: false,
              prefixIconData: Icons.person,
            ),
            CustomTextFieldWidget(
              onSaved: (value) {
                setState(() {
                  _email = value!;
                });
              },
              onChanged: (value) => _email = value,
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: 'Email',
              validator: validateEmail,
              obscureText: false,
              prefixIconData: Icons.mail_outline,
            ),
            CustomTextFieldWidget(
              onSaved: (value) {
                setState(() {
                  _password = value;
                });
              },
              onChanged: (value) => _password = value,
              regEx: r".{6,}",
              validator: validatePassword,
              hintText: 'Password',
              obscureText: false,
              prefixIconData: Icons.lock_outline,
            ),
            CustomTextFieldWidget(
              onSaved: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
              onChanged: (value) => _confirmPassword = value,
              regEx: r".{6,}",
              validator: validateConfirmPassword,
              hintText: 'Confirm Password',
              obscureText: false,
              prefixIconData: Icons.lock_outline,
            )
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        checkEmail = false;
        checkUsername = false;
        try {
          // Fetch the sign-in methods associated with the email address
          final list =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(_email!);

          // In case list is not empty
          if (list.isNotEmpty) {
            checkEmail = true;
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-email') {
            // handle invalid email error
          }
        }

        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('username', isEqualTo: _username)
            .get();

        final List<DocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          checkUsername = true;
        }
        // Validate the registration form and profile image is not null
        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          // Save the registration form
          _registerFormKey.currentState!.save();

          // Register the user using email and password
          String? uid = await _auth.registerUserUsingEmailAndPassword(
              _email!, _password!);

          // Save user image to storage and get the image URL
          String? imageURL =
              await _cloudStorage.saveUserImageToStorage(uid!, _profileImage!);

          // Create user in the Firestore database
          await _db.createUser(uid, _email!, _username!, imageURL!);

          // Logout the user
          _auth.logout();

          // Login the user using email and password
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        }
      },
    );
  }
}
