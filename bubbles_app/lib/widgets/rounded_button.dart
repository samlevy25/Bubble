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
        color: empty ? const Color(0xffffffff) : Colors.lightBlue,
        border: empty
            ? Border.all(
                color: Colors.lightBlue,
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
            color: empty ? Colors.lightBlue : const Color(0xffffffff),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
