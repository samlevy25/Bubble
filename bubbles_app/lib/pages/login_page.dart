import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// w
import '../widgets/rounded_button.dart';

//p
import '../providers/authentication_provider.dart';
import '/pages/ResetPasswordPage.dart';

//s
import '../services/navigation_service.dart';
import '../widgets/CustomTextField_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignIn();
  }
}

class _SignIn extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late bool keyboardOpen;
  bool isPasswordVisible = true;

  late final _loginFormKey = GlobalKey<FormState>();

  late String? _email;
  late bool checkEmail;
  String? _password;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
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
    String pattern = r".{6,}";
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid password.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    _email = "";
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SingleChildScrollView(
        child: Container(
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
              const SizedBox(
                height: 10.0,
              ),
              Image.asset(
                'assets/images/login.png',
                alignment: Alignment.topCenter,
                height: _deviceHeight * 0.3,
              ),
              const SizedBox(
                height: 35.0,
              ),
              const SizedBox(
                height: 20.0,
              ),
              _loginForm(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const ResetPasswordPage();
                      },
                    ));
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.lightBlue),
                  ),
                  child: const Text('Forgot password ?'),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              _loginBottun(),
              const SizedBox(
                height: 10.0,
              ),
              _SignUpBottun(e: true),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SizedBox(
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              onSaved: (value) {
                setState(() {
                  _email = value;
                });
              },
              validator: validateEmail,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.mail_outline,
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
            const SizedBox(
              height: 10.0,
            ),
            TextFormField(
              onSaved: (value) {
                setState(() {
                  _password = value;
                });
              },
              obscureText: isPasswordVisible,
              validator: validatePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.lightBlue,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
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
          ],
        ),
      ),
    );
  }

  Widget _loginBottun({bool? e}) {
    return RoundedButton(
      empty: e ?? false,
      name: "Login",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        checkEmail = false;

        if (_loginFormKey.currentState!.validate()) {
          _loginFormKey.currentState!.save();
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        } else {}
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _SignUpBottun({bool? e}) {
    return RoundedButton(
      empty: e ?? false,
      name: "Sign Up",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () {
        _navigation.navigateToRoute('/register');
      },
    );
  }
}
