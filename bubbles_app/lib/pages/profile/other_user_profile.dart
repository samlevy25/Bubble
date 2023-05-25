import 'package:bubbles_app/models/app_user.dart';
import 'package:flutter/material.dart';

class OtherUserProfile extends StatelessWidget {
  final AppUser user;

  const OtherUserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Profile'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.imageURL),
            radius: 40,
          ),
          const SizedBox(height: 10),
          Text(user.username),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Open chat with the user
              // Implement the logic to open the chat screen here
              Navigator.of(context).pop();
              // Implement the logic to open the chat screen
            },
            child: const Text('Chat'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Report the user
              // Implement the logic to report the user here
              Navigator.of(context).pop();
              // Implement the logic to report the user
            },
            child: const Text('Report'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
