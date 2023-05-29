import 'package:flutter/material.dart';

class CreatePostDialog extends StatelessWidget {
  final Function(String) onPostCreated; // Callback function

  const CreatePostDialog({Key? key, required this.onPostCreated})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String postContent = ''; // Local variable to hold the post content

    return AlertDialog(
      title: const Text('Create Post'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Post Content',
              ),
              maxLines: null,
              onChanged: (value) {
                postContent = value; // Update the post content
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Post'),
          onPressed: () {
            onPostCreated(
                postContent); // Pass the post content back to ExplorerPage
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
