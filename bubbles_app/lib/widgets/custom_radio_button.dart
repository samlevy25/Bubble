import 'package:flutter/material.dart';

class MyRadioListTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String title;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final double width;

  const MyRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _customRadioButton,
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    final isSelected = value == groupValue;
    return Padding(
      padding: EdgeInsets.all(width * 0.1),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.red : null,
              size: width * 0.9,
            ),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.red : null,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
