import 'package:bubbles_app/widgets/custom_input_fields.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:async_button_builder/async_button_builder.dart';
import '../providers/authentication_provider.dart';
import '../services/database_service.dart';

import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_radio_button.dart';
import '../widgets/profile_widget.dart';

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
  late DatabaseService _db;

  String? _currentPassword;
  // image
  String? _username;
  final _usernameFormKey = GlobalKey<FormState>();

  // email
  String? _email;
  final _emailFormKey = GlobalKey<FormState>();

  // password
  String? _newPassword;
  final _passwordFormKey = GlobalKey<FormState>();

  double _currentSliderValue = 0;
  String _lang = "EN";

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);
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
        Form(
          child: ProfileWidget(
            isEdit: true,
            imagePath: _auth.appUser.imageURL,
            onClicked: () {},
          ),
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

            return validate
                ? TextButton(
                    onPressed: callback,
                    child: child,
                  )
                : TextButton(
                    onPressed: callback,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: child,
                  );
          },
          child: const Text('Apply'),
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

            return validate
                ? TextButton(
                    onPressed: callback,
                    child: child,
                  )
                : TextButton(
                    onPressed: callback,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: child,
                  );
          },
          child: const Text('Apply'),
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
        TextButton(
          child: const Text("Apply"),
          onPressed: () async {
            if (_passwordFormKey.currentState!.validate()) {
              _passwordFormKey.currentState!.save();
              _auth.changePassword(_newPassword, _currentPassword);
            }
          },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyRadioListTile(
              value: "EN",
              groupValue: _lang,
              title: "GPS",
              onChanged: (value) => setState(() => _lang = value!),
              icon: Icons.gps_fixed,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: "HEB",
              groupValue: _lang,
              title: "WIFI",
              onChanged: (value) => setState(() => _lang = value!),
              icon: Icons.wifi,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: "FR",
              groupValue: _lang,
              title: "NFC",
              onChanged: (value) => setState(() => _lang = value!),
              icon: Icons.nfc,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: "RUS",
              groupValue: _lang,
              title: "Password",
              onChanged: (value) => setState(() => _lang = value!),
              icon: Icons.key,
              width: _deviceWidth * 0.1,
            ),
          ],
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
