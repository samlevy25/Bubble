import 'package:bubbles_app/widgets/custom_input_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/src/platform_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:async_button_builder/async_button_builder.dart';
import '../../providers/authentication_provider.dart';
import '../../services/cloud_storage_service.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../services/media_service.dart';

import '../../widgets/rounded_image.dart';

import 'package:list_picker/list_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  bool validate = true;
  UserCredential? authResult;
  late AuthenticationProvider _auth;
  late CloudStorageService _cloudStorage;
  late DatabaseService _db;

  // current password for re-auth
  String? _currentPassword = "";

  //Check for re-auth
  bool checkAuth = false;

  // image
  PlatformFile? _profileImage;

  //username
  String? _username = "";
  final _usernameFormKey = GlobalKey<FormState>();
  bool checkUsername = false;
  bool sameUsername = false;
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a User name.';
    }

    RegExp regExp = RegExp(r".{8,}");
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid User name.';
    }

    if (sameUsername) {
      return "Entered current Username. Please provide a new one.";
    }

    if (checkUsername) {
      return "The Username is already used.";
    }

    return null;
  }

  Future<bool> checkUsernameExists(String? username) async {
    final collection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot =
        await collection.where('username', isEqualTo: username).get();

    return querySnapshot.docs.isNotEmpty;
  }

  // email
  String? _email = "";
  final _emailFormKey = GlobalKey<FormState>();
  bool checkEmail = false;
  bool sameEmail = false;
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }

    RegExp regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }

    if (sameEmail) {
      return "Entered current email. Please provide a new one.";
    }

    if (checkEmail) {
      return "The Email is already used.";
    }

    return null;
  }

  Future<bool> checkEmailExists(String? email) async {
    final collection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot =
        await collection.where('email', isEqualTo: email).get();

    return querySnapshot.docs.isNotEmpty;
  }

  String? validatePasswordForEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    if (!regExp.hasMatch(value)) {
      return 'Password must be at least 6 characters long.';
    }

    if (checkAuth) {
      return "The password is wrong, please try again !";
    }

    return null;
  }

  // password
  String? _newPassword = "";
  String? _confirmPassword = "";
  bool samePassword = false;
  bool _confirm = false;
  final _passwordFormKey = GlobalKey<FormState>();
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    // RegExp(r".{6,}").hasMatch(_newPassword)

    if (!regExp.hasMatch(value)) {
      return 'Password must be at least 6 characters long.';
    }

    if (samePassword) {
      return "Entered current password. Please provide a new one.";
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the confirm password.';
    }

    RegExp regExp = RegExp(r".{6,}");

    if (!regExp.hasMatch(value)) {
      return 'Confim password must be at least 6 characters long.';
    }

    if (_confirm &&
        ((!samePassword && RegExp(r".{6,}").hasMatch(_newPassword!)))) {
      return "Password and confirmation do not match.";
    }

    return null;
  }

  // radius
  double _currentSliderValue = 0;
  // lang

  String? lang;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _db = GetIt.instance.get<DatabaseService>();

    return _buildUI();
  }

  Widget _buildUI() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          backgroundColor: Colors.lightBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            "Settings",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            const ListTile(title: Text("Profile")),
            _changeProfileImage(),
            _changeUsername(),
            const ListTile(title: Text("Security")),
            _changeEmail(),
            _changePassword(),
            const ListTile(title: Text("App")),
            _changeLanguage(),
            _changeRadius(),
            _logout(),
            const ListTile(title: Text("About")),
            _aboutLink(),
          ],
        ),
      ),
    );
  }

// Profile
  Widget _changeProfileImage() {
    return ExpansionTile(
      leading: const Icon(Icons.image),
      title: const Text('Profile Image'),
      subtitle: const Text('change the display Image'),
      children: [
        GestureDetector(
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
                    imagePath: _auth.appUser.imageURL,
                    size: _deviceHeight * 0.15,
                  );
          }(),
        ),
        AsyncButtonBuilder(
          onPressed: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (_profileImage != null) {
              validate = true;
              String? imageURL = await _cloudStorage.saveUserImageToStorage(
                  _auth.appUser.uid, _profileImage!);
              _db.updateImageURL(_auth.appUser.uid, imageURL!);
            } else {
              validate = false;
              throw 'yikes';
            }
          },
          builder: (context, child, callback, buttonState) {
            final buttonColor = buttonState.when(
              idle: () => null,
              loading: () => null,
              success: () => null,
              error: (err, stack) => null,
            );

            return TextButton(
              onPressed: callback,
              style: validate
                  ? null
                  : OutlinedButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
              child: child,
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _changeUsername() {
    return ExpansionTile(
      leading: const Icon(Icons.person),
      title: const Text('Username'),
      subtitle: const Text('change the display username'),
      children: [
        Form(
          key: _usernameFormKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03,
                vertical: _deviceHeight * 0.01),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
              validator: validateUsername,
              decoration: InputDecoration(
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
                labelText: "New Username",
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0)
              .copyWith(bottom: _deviceHeight * 0.01),
          child: ElevatedButton(
            onPressed: () async {
              checkUsername = false;
              sameUsername = false;

              if (_auth.appUser.username == _username) {
                sameUsername = true;
              }
              if (await checkUsernameExists(_username)) {
                checkUsername = true;
              }

              if (_usernameFormKey.currentState!.validate()) {
                validate = true;
                _usernameFormKey.currentState!.save();
                _db.updateUsername(_auth.appUser.uid, _username);
              } else {
                validate = false;
              }
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  //Security
  Widget _changeEmail() {
    return ExpansionTile(
      leading: const Icon(Icons.email),
      title: const Text('Email'),
      subtitle: const Text('Change the login email'),
      children: [
        Form(
          key: _emailFormKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.01),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                    });
                  },
                  validator: validatePasswordForEmail,
                  decoration: InputDecoration(
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
                    labelText: "Current password",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.01),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  validator: validateEmail,
                  decoration: InputDecoration(
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
                    labelText: "New Email",
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0)
              .copyWith(bottom: _deviceHeight * 0.01),
          child: ElevatedButton(
            onPressed: () async {
              checkEmail = false;
              checkAuth = false;
              sameEmail = false;
              authResult = await _auth.changeEmail(_email, _currentPassword);

              if (_auth.appUser.email == _email) {
                sameEmail = true;
              }

              if (await checkEmailExists(_email)) {
                checkEmail = true;
              }

              if (authResult == null) {
                checkAuth = true;
              }

              if (_emailFormKey.currentState!.validate()) {
                _emailFormKey.currentState!.save();
                await authResult?.user?.updateEmail(_email!);
                _db.updateEmail(_auth.appUser.uid, _email);
              }
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _changePassword() {
    return ExpansionTile(
      leading: const Icon(Icons.password),
      title: const Text('Password'),
      subtitle: const Text('change the login password'),
      children: [
        Form(
          key: _passwordFormKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.01),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                    });
                  },
                  validator: validatePasswordForEmail,
                  decoration: InputDecoration(
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
                    labelText: "Current password",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.01),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                    });
                  },
                  validator: validatePassword,
                  decoration: InputDecoration(
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
                    labelText: "New password",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.01),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _confirmPassword = value;
                    });
                  },
                  validator: validateConfirmPassword,
                  decoration: InputDecoration(
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
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0)
              .copyWith(bottom: _deviceHeight * 0.01),
          child: ElevatedButton(
            onPressed: () async {
              checkAuth = false;
              _confirm = false;
              authResult =
                  await _auth.changePassword(_newPassword, _currentPassword);
              samePassword = false;

              if (authResult == null) {
                checkAuth = true;
              } else {
                if (_currentPassword == _newPassword) {
                  samePassword = true;
                }
              }
              print(
                  "Confirm password : $_confirmPassword  --  New Password : $_newPassword");
              if (_confirmPassword != _newPassword) {
                _confirm = true;
              }

              if (_passwordFormKey.currentState!.validate()) {
                _passwordFormKey.currentState!.save();
                await authResult?.user?.updatePassword(_newPassword!);
              }
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  //App
  Widget _changeLanguage() {
    return ExpansionTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: const Text('change App Language'),
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              lang = await showDialog(
                context: context,
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Select your Language'),
                  ),
                  body: const ListPickerDialog(
                    label: "Language",
                    items: [
                      'Afrikaans',
                      'Albanian',
                      'Amharic',
                      'Arabic',
                      'Armenian',
                      'Azerbaijani',
                      'Basque',
                      'Belarusian',
                      'Bengali',
                      'Bosnian',
                      'Bulgarian',
                      'Catalan',
                      'Cebuano',
                      'Chichewa',
                      'Chinese (Simplified)',
                      'Chinese (Traditional)',
                      'Corsican',
                      'Croatian',
                      'Czech',
                      'Danish',
                      'Dutch',
                      'English',
                      'Esperanto',
                      'Estonian',
                      'Filipino',
                      'Finnish',
                      'French',
                      'Frisian',
                      'Galician',
                      'Georgian',
                      'German',
                      'Greek',
                      'Gujarati',
                      'Haitian Creole',
                      'Hausa',
                      'Hawaiian',
                      'Hebrew',
                      'Hindi',
                      'Hmong',
                      'Hungarian',
                      'Icelandic',
                      'Igbo',
                      'Indonesian',
                      'Irish',
                      'Italian',
                      'Japanese',
                      'Javanese',
                      'Kannada',
                      'Kazakh',
                      'Khmer',
                      'Kinyarwanda',
                      'Korean',
                      'Kurdish (Kurmanji)',
                      'Kurdish (Sorani)',
                      'Kyrgyz',
                      'Lao',
                      'Latin',
                      'Latvian',
                      'Lithuanian',
                      'Luxembourgish',
                      'Macedonian',
                      'Malagasy',
                      'Malay',
                      'Malayalam',
                      'Maltese',
                      'Maori',
                      'Marathi',
                      'Mongolian',
                      'Myanmar (Burmese)',
                      'Nepali',
                      'Norwegian',
                      'Odia (Oriya)',
                      'Pashto',
                      'Persian',
                      'Polish',
                      'Portuguese',
                      'Punjabi',
                      'Romanian',
                      'Russian',
                      'Samoan',
                      'Scots Gaelic',
                      'Serbian',
                      'Sesotho',
                      'Shona',
                      'Sindhi',
                      'Sinhala',
                      'Slovak',
                      'Slovenian',
                      'Somali',
                      'Spanish',
                      'Sundanese',
                      'Swahili',
                      'Swedish',
                      'Tajik',
                      'Tamil',
                      'Tatar',
                      'Telugu',
                      'Thai',
                      'Turkish',
                      'Turkmen',
                      'Ukrainian',
                      'Urdu',
                      'Uyghur',
                      'Uzbek',
                      'Vietnamese',
                      'Welsh',
                      'Xhosa',
                      'Yiddish',
                      'Yoruba',
                      'Zulu'
                    ],
                  ),
                ),
              );
            },
            child: const Text('Select your Language'),
          ),
        ),
      ],
    );
  }

  Widget _changeRadius() {
    return ExpansionTile(
      leading: const Icon(Icons.gps_fixed),
      title: const Text('Radius'),
      subtitle: const Text('change the Radius'),
      children: [
        Slider(
          value: _currentSliderValue,
          max: 3,
          min: 0,
          divisions: 3,
          label: ["30m", "150m", "1Km", "5Km"][_currentSliderValue.round()],
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
        ),
      ],
    );
  }

  Widget _logout() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text("Logout"),
      onTap: () {
        _auth.logout();
      },
    );
  }

  Widget _aboutLink() {
    final Uri _url = Uri.parse('https://bubbles-website-716a4.web.app/');
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text("About our project"),
      onTap: () async {
        if (!await launchUrl(_url)) {
          throw Exception('Could not launch $_url');
        }
      },
    );
  }
}
