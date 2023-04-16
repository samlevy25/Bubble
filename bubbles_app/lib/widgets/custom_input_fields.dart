import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String hintText;
  final bool obscureText;

  const CustomTextFormField(
      {super.key,
      required this.onSaved,
      required this.regEx,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (value) => onSaved(value!),
      cursorColor: const Color.fromARGB(255, 108, 81, 81),
      style: const TextStyle(color: Color.fromARGB(255, 141, 43, 43)),
      obscureText: obscureText,
      validator: (value) {
        return RegExp(regEx).hasMatch(value!) ? null : "Error";
      },
      decoration: InputDecoration(
        fillColor: Color.fromARGB(255, 255, 255, 255),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(136, 88, 36, 36)),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Function(String) onEditingComplete;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData? icon;

  const CustomTextField(
      {super.key,
      required this.onEditingComplete,
      required this.hintText,
      required this.obscureText,
      required this.controller,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onEditingComplete: () => onEditingComplete(controller.value.text),
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: const Color.fromRGBO(30, 29, 37, 1.0),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
      ),
    );
  }
}
