import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final Color mediumBlue = const Color.fromARGB(255, 21, 0, 255);
  final String? text;
  final String regEx;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextFieldWidget({
    Key? key,
    this.hintText,
    this.text,
    this.prefixIconData,
    this.suffixIconData,
    this.onChanged,
    this.controller,
    this.validator,
    required this.onSaved,
    required this.regEx,
    required this.obscureText,
  }) : super(key: key);

  @override
  _CustomTextFieldWidgetState createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  onSaved(String? value) {
    if (widget.onSaved != null) {
      widget.onSaved!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      controller: TextEditingController(text: widget.text),
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      cursorColor: widget.mediumBlue,
      validator: widget.validator,
      style: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: widget.mediumBlue),
        focusColor: widget.mediumBlue,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: widget.mediumBlue),
        ),
        labelText: widget.hintText,
        prefixIcon: Icon(
          widget.prefixIconData,
          size: 18,
          color: widget.mediumBlue,
        ),
        suffixIcon: GestureDetector(
          onTap: () {},
          child: Icon(
            widget.suffixIconData,
            size: 18,
            color: widget.mediumBlue,
          ),
        ),
      ),
    );
  }
}
