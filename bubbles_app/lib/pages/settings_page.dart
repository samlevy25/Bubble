import 'package:bubbles_app/widgets/custom_input_fields.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:file_picker/src/platform_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:async_button_builder/async_button_builder.dart';
import '../providers/authentication_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';

import 'package:url_launcher/url_launcher.dart';

import '../services/media_service.dart';
import '../widgets/custom_radio_button.dart';
import '../widgets/profile_widget.dart';
import '../widgets/rounded_image.dart';

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

  late AuthenticationProvider _auth;
  late CloudStorageService _cloudStorage;
  late DatabaseService _db;

  // current password for re-auth
  String? _currentPassword;

  // image
  PlatformFile? _profileImage;

  //username
  String? _username;
  final _usernameFormKey = GlobalKey<FormState>();

  // email
  String? _email;
  final _emailFormKey = GlobalKey<FormState>();

  // password
  String? _newPassword;
  final _passwordFormKey = GlobalKey<FormState>();

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
          title: const Text("Settings"),
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
          child: CustomTextFormField(
            onSaved: (value) {
              setState(() {
                _username = value;
              });
            },
            regEx: r'.{8,}',
            hintText: "Enter your new username here",
            obscureText: false,
          ),
        ),
        AsyncButtonBuilder(
          onPressed: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (_usernameFormKey.currentState!.validate()) {
              validate = true;
              _usernameFormKey.currentState!.save();
              _db.updateUsername(_auth.appUser.uid, _username);
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

  //Security
  Widget _changeEmail() {
    return ExpansionTile(
      leading: const Icon(Icons.email),
      title: const Text('Email'),
      subtitle: const Text('change the login email'),
      children: [
        Form(
          key: _emailFormKey,
          child: Column(
            children: [
              CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Enter your new email here",
                obscureText: false,
              ),
              CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _currentPassword = value;
                  });
                },
                regEx: r'.{8,}',
                hintText: "Enter your current password ",
                obscureText: true,
              ),
            ],
          ),
        ),
        AsyncButtonBuilder(
          onPressed: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (_emailFormKey.currentState!.validate()) {
              validate = true;
              _emailFormKey.currentState!.save();
              _auth.changeEmail(_email, _currentPassword);
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
              CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _currentPassword = value;
                  });
                },
                regEx: r'.{8,}',
                hintText: "Enter your current password ",
                obscureText: true,
              ),
              CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _newPassword = value;
                  });
                },
                regEx: r'.{8,}',
                hintText: "Enter your new password here",
                obscureText: true,
              ),
            ],
          ),
        ),
        AsyncButtonBuilder(
          onPressed: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (_passwordFormKey.currentState!.validate()) {
              validate = true;
              _passwordFormKey.currentState!.save();
              _auth.changePassword(_newPassword, _currentPassword);
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

//about
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
