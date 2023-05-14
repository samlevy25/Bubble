import 'package:flutter/material.dart';

class PostTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String hintText;
  final bool obscureText;

  const PostTextFormField({
    Key? key,
    required this.onSaved,
    required this.regEx,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0, // Set a fixed height for the container
      child: TextFormField(
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        onSaved: (value) => onSaved(value!),
        cursorColor: const Color.fromARGB(255, 108, 81, 81),
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        validator: (value) {
          return RegExp(regEx).hasMatch(value!) ? null : "Error";
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.blue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(136, 88, 36, 36)),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 75.0, horizontal: 16.0), // Adjust the padding as needed
        ),
      ),
    );
  }
}
