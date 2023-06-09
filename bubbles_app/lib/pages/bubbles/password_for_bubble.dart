import 'package:flutter/material.dart';

Future<String?> showPasswordDialog(
    BuildContext context, bool enableRetype) async {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String? passwordError;

  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Enter Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    errorText: passwordError,
                  ),
                ),
                if (enableRetype)
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  String? password = passwordController.text;

                  if (password.length >= 8 &&
                      (!enableRetype ||
                          password == confirmPasswordController.text)) {
                    Navigator.of(context).pop(password);
                  } else {
                    setState(() {
                      passwordError =
                          "Passwords do not match or are less than 8 characters long";
                    });
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
