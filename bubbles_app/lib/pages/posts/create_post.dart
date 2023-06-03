import 'package:flutter/material.dart';

class CreatePostDialog extends StatefulWidget {
  final Function(String) onPostCreated;

  const CreatePostDialog({Key? key, required this.onPostCreated})
      : super(key: key);

  @override
  _CreatePostDialogState createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  late TextEditingController _textEditingController;
  final int maxCharacterLimit = 200; // Maximum character limit for the post

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            20.0), // Adjust the radius as per your preference
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'What\'s on your mind?',
                  contentPadding: EdgeInsets.all(8.0),
                ),
                maxLength: maxCharacterLimit,
              ),
              ElevatedButton(
                child: const Text('Post'),
                onPressed: () {
                  final postContent = _textEditingController.text.trim();
                  if (postContent.isNotEmpty) {
                    widget.onPostCreated(postContent);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
