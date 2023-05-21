import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/bubble_key_types.dart';

import '../../models/bubble.dart';
import '../../networks/gps.dart';
import '../../widgets/rounded_image.dart';
import 'bubble_page.dart';

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
          return buildBubbleTile(locationName);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget buildBubbleTile(String locationName) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.bubble.keyType.gradient,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        trailing: Icon(widget.bubble.keyType.icon),
        leading: RoundedImageNetwork(
          imagePath: widget.bubble.image,
          key: ValueKey(widget.bubble.uid),
          size: 50,
        ),
        title: buildBubbleTitle(),
        children: [
          Column(
            children: [
              buildBubbleDescription(),
              if (widget.bubble.keyType == BubbleKeyType.password &&
                  showPasswordInput)
                buildPasswordInput(),
              buildButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBubbleTitle() {
    return Text(
      widget.bubble.name,
      style: TextStyle(color: Colors.white),
    );
  }

  Widget buildPasswordInput() {
    return Container(
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
    );
  }

  Widget buildButton() {
    return TextButton(
      onPressed: () async {
        if (widget.bubble.keyType == BubbleKeyType.password &&
            !showPasswordInput) {
          setState(() {
            showPasswordInput = true;
          });
        } else {
          if (widget.bubble.keyType == BubbleKeyType.password) {
            final enteredPassword = passwordController.text.trim();
            if (enteredPassword != '123') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Invalid Password'),
                    content: const Text('Please enter a valid password.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
          }
          
          // Navigate to bubble
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BubblePage(bubble: widget.bubble),
            ),
          );
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: const Text('Join'),
    );
  }

  Widget buildBubbleDescription() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              widget.bubble.description,
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic, // Set the font style to italic
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 5.0),
            Text(
              widget.bubble.geohash,
              style: TextStyle(color: Colors.white),
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
        )
      ],
    );
  }
}
