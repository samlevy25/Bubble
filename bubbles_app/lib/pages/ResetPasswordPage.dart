import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';
  bool _isMailSent = false;
  late double _deviceHeight;
  late double _deviceWidth;
  bool checkEmail = false;
  String? _email = "";

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {
      _errorMessage = '';
    });
  }

  Future<bool> checkEmailExists(String? email) async {
    final collection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot =
        await collection.where('email', isEqualTo: email).get();

    return !querySnapshot.docs.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reset Password'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: _deviceHeight * 0.01),
            Image.asset('assets/images/resetPassword.png'),
            SizedBox(height: _deviceHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.03),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                        children: [
                          TextSpan(text: 'Enter your '),
                          TextSpan(
                            text: 'email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                              text:
                                  ' adress and we will send you instructions to reset your password.'),
                        ],
                      ),
                    ),
                    SizedBox(height: _deviceHeight * 0.04),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _isMailSent
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: _deviceHeight * 0.024),
                              child: const Center(
                                child: Text(
                                  'Mail Sent!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  key: Key('MailSent'),
                                ),
                              ),
                            )
                          : TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _email = value;
                                });
                              },
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelStyle:
                                    const TextStyle(color: Colors.lightBlue),
                                focusColor: Colors.lightBlue,
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.lightBlue),
                                ),
                                labelText: "Email",
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  size: 18,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }

                                RegExp regExp = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                                if (!regExp.hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }

                                if (checkEmail) {
                                  return "Email doesn't exist";
                                }

                                return null;
                              },
                            ),
                    ),
                    SizedBox(height: _deviceHeight * 0.02),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          checkEmail = false;

                          if (await checkEmailExists(_email)) {
                            checkEmail = true;
                          }

                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                email: _emailController.text.trim(),
                              );
                              setState(() {
                                _isMailSent = true;
                              });
                              Future.delayed(const Duration(seconds: 3), () {
                                setState(() {
                                  _isMailSent = false;
                                });
                              });
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _errorMessage = e.message!;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: _deviceWidth * 0.1,
                              vertical: _deviceHeight * 0.025),
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
