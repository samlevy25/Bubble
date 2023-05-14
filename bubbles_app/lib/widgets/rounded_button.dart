//Packages
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Function onPressed;
  final bool empty;

  const RoundedButton({
    super.key,
    required this.name,
    required this.height,
    required this.width,
    required this.onPressed,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.25),
        color: empty
            ? const Color(0xffffffff)
            : const Color.fromARGB(255, 21, 0, 255),
        border: empty
            ? Border.all(
                color: const Color.fromARGB(255, 21, 0, 255),
                width: 1.0,
              )
            : const Border.fromBorderSide(BorderSide.none),
      ),
      child: TextButton(
        onPressed: () => onPressed(),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 22,
            color: empty
                ? const Color.fromARGB(255, 21, 0, 255)
                : const Color(0xffffffff),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
