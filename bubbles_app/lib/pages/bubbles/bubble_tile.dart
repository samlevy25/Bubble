import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/enums.dart';
import '../../constants/colors.dart';
import '../../models/bubble.dart';
import '../../networks/gps.dart';
import '../../widgets/rounded_image.dart';

class BubbleTile extends StatefulWidget {
  final Bubble bubble;

  const BubbleTile({Key? key, required this.bubble}) : super(key: key);

  @override
  State<BubbleTile> createState() => _BubbleTileState();
}

class _BubbleTileState extends State<BubbleTile> {
  bool showPasswordInput = false;
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCurrentLocationName(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final locationName = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              gradient: getGradientColorForBubble(widget.bubble.uid),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              trailing: Icon(
                [
                  Icons.wifi,
                  Icons.nfc,
                  Icons.password,
                  Icons.bluetooth,
                ][0],
              ),
              leading: RoundedImageNetwork(
                imagePath: widget.bubble.image,
                key: ValueKey(widget.bubble.uid),
                size: 50,
              ),
              title: Text(
                widget.bubble.name,
                style: const TextStyle(color: Colors.white),
              ),
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 5.0),
                        Text(
                          locationName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 5.0),
                        Text(
                          widget.bubble.members.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    if (showPasswordInput)
                      Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 8.0,
                            ),
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        if (true) {
                          setState(() {
                            showPasswordInput = true;
                          });
                        } else {
                          await Future.delayed(const Duration(seconds: 1));
                          throw Exception("yo yo");
                        }
                      },
                      child: const Text(
                        'Click Me',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  LinearGradient getGradientColorForBubble(String uid) {
    final Random random = Random(uid.hashCode);
    final int randomIndex = random.nextInt(gradientColors.length);
    return gradientColors[randomIndex];
  }
}
