import '../widgets/popups.dart';
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import '../models/bubble.dart';

class BubbleTile extends StatelessWidget {
  const BubbleTile({super.key, required this.bubble});
  final Bubble bubble;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
            child: Card(
              color: const Color.fromARGB(204, 104, 225, 234),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(bubble.getName()),
                    leading: RoundedImageNetwork(
                      imagePath: bubble.getImageURL(),
                      size: deviceHeight * 0.06,
                      key: UniqueKey(),
                    ),
                  )
                ],
              ),
            ),
            onPressed: () => bubblePopup(context, bubble))
      ],
    );
  }
}
