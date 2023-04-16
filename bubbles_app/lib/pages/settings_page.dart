import 'package:bubbles_app/widgets/custom_input_fields.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../services/database_service.dart';

import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_radio_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;

  String? _username;
  final _usernameFormKey = GlobalKey<FormState>();
  String? _email;
  final _emailFormKey = GlobalKey<FormState>();
  String? _password;
  final _passwordFormKey = GlobalKey<FormState>();

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
      children: [Container()],
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
        TextButton(
          child: const Text("Apply"),
          onPressed: () async {
            if (_usernameFormKey.currentState!.validate()) {
              _usernameFormKey.currentState!.save();
              _db.updateUsername(_auth.appUser.uid, _username);
            }
          },
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
          child: CustomTextFormField(
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
        ),
        TextButton(
          child: const Text("Apply"),
          onPressed: () async {
            if (_emailFormKey.currentState!.validate()) {
              _emailFormKey.currentState!.save();
              _auth.changeEmail(_email);
            }
          },
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
          child: CustomTextFormField(
            onSaved: (value) {
              setState(() {
                _password = value;
              });
            },
            regEx: r'.{8,}',
            hintText: "Enter your new password here",
            obscureText: true,
          ),
        ),
        TextButton(
          child: const Text("Apply"),
          onPressed: () async {
            if (_passwordFormKey.currentState!.validate()) {
              _passwordFormKey.currentState!.save();
              _auth.changePassword(_password);
            }
          },
        ),
      ],
    );
  }

  //App
  Widget _changeLanguage() {
    return ExpansionTile(
      leading: const Icon(Icons.gps_fixed),
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
      children: [Container()],
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
