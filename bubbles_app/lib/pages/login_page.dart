//Packages
import 'package:flutter/material.dart';

// w
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pageTitle(),
            _loginForm(),
            _loginBottun(),
            _registerAccountLink()
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.10,
      child: const Text(
        'Bubbles',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SizedBox(
      height: _deviceHeight * 0.18,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFromField(
              onSaved: (_value) {},
              regEx: r'^[a-zA-Z0-9]+$',
              hintText: "Email",
              obscureText: false,
            ),
            CustomTextFromField(
              onSaved: (_value) {},
              regEx: r'^[a-zA-Z0-9]+$',
              hintText: "Password",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginBottun() {
    return RoundedButton(
      name: "Login",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () {},
    );
  }

  Widget _registerAccountLink() {
    return GestureDetector(
      onTap: () {
        print("Clicked!");
      },
      child: Container(
        child: const Text(
          "account",
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
