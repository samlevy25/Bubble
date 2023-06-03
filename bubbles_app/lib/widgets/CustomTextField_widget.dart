import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final Color lightBlue = Colors.lightBlue;
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  onSaved(String? value) {
    if (widget.onSaved != null) {
      widget.onSaved!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      controller: _controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      cursorColor: widget.lightBlue,
      validator: widget.validator,
      style: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: widget.lightBlue),
        focusColor: widget.lightBlue,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: widget.lightBlue),
        ),
        labelText: widget.hintText,
        prefixIcon: Icon(
          widget.prefixIconData,
          size: 18,
          color: widget.lightBlue,
        ),
        suffixIcon: GestureDetector(
          onTap: () {},
          child: Icon(
            widget.suffixIconData,
            size: 18,
            color: widget.lightBlue,
          ),
        ),
      ),
    );
  }
}
