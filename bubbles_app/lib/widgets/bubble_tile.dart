import 'package:bubbles_app/pages/bubble_page.dart';
import 'package:bubbles_app/services/navigation_service.dart';
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/bubble.dart';

class BubbleTile extends StatelessWidget {
  const BubbleTile({super.key, required this.bubble});
  final Bubble bubble;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    NavigationService navigation = GetIt.instance.get<NavigationService>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: Card(
            color: Color.fromARGB(204, 104, 225, 234),
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
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: SizedBox(
                height: deviceHeight * 0.5,
                width: deviceWidth * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundedImageNetwork(
                        imagePath: bubble.getImageURL(),
                        size: deviceHeight * 0.2,
                        key: UniqueKey(),
                      ),
                      Text("Name: ${bubble.getName()}"),
                      Text("Location: ${bubble.getLocation()}"),
                      Text("Memmbers: ${bubble.getLenght()}"),
                      Text("KeyType: ${bubble.getMethod()}"),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              navigation
                                  .navigateToPage(BubblePage(bubble: bubble));
                            },
                            child: const Text('Join'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
