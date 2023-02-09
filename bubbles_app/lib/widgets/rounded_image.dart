import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RoundedImageFile extends StatelessWidget {
  final PlatformFile image;
  final double size;

  RoundedImageFile({
    required Key key,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(image.path!),
          ),
          borderRadius: BorderRadius.all(Radius.circular(size))),
    );
  }
}

class DefaultRoundedImage extends StatelessWidget {
  final double size;

  DefaultRoundedImage({
    required Key key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/no_pic.png'),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(size),
        ),
        color: Colors.black,
      ),
    );
  }
}
