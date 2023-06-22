import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

// w
import '../widgets/rounded_button.dart';

//p
import '../providers/authentication_provider.dart';
import '/pages/ResetPasswordPage.dart';

//s
import '../services/navigation_service.dart';

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
  late ProgressDialog pr;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late bool keyboardOpen;
  bool isPasswordVisible = true;
  String? _loginError = "";

  late final _loginFormKey = GlobalKey<FormState>();

  String? _email = "";
  late bool checkEmail;
  String? _password = "";

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Invalid email. Use format: 'name@example.com'.";
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
    pr = ProgressDialog(context);
    pr.style(message: "Connecting...");

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.05,
            ),
            height: _deviceHeight,
            width: _deviceWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/login.png',
                    alignment: Alignment.topCenter,
                    height: _deviceHeight * 0.35,
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Welcome,",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Sign in to continue !",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _deviceHeight * 0.03,
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
                  _loginButton(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Expanded(
                          child: Divider(
                            color: Colors.black54,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "or",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black54,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SignUpBottun(e: true),
                ],
              ),
            ),
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
              onChanged: (value) {
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            TextFormField(
              onChanged: (value) {
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
            if (_loginError != null)
              Text(
                _loginError!,
                style: TextStyle(
                  color: Colors.red[(700)],
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton({bool? e}) {
    return RoundedButton(
      empty: e ?? false,
      name: "Login",
      height: _deviceHeight * 0.065,
      width: _deviceWidth,
      onPressed: () async {
        checkEmail = false;

        if (_loginFormKey.currentState!.validate()) {
          _loginFormKey.currentState!.save();

          await pr.show();

          String? userId =
              await _auth.loginUsingEmailAndPassword(_email!, _password!);

          if (userId != null) {
            setState(() {
              _loginError = null;
            });
          } else {
            setState(() {
              _loginError = 'Invalid email or password';
            });
          }
        } else {
          setState(() {
            _loginError = null;
          });
        }

        await pr.hide();
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _SignUpBottun({bool? e}) {
    return RoundedButton(
      empty: e ?? false,
      name: "Sign Up",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 1,
      onPressed: () {
        _navigation.navigateToRoute('/register');
      },
    );
  }
}
