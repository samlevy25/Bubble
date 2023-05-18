import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform your post creation logic here
      String title = _titleController.text;
      String content = _contentController.text;
      // Call an API, update the database, etc.

      // Reset the form
      _formKey.currentState!.reset();
      _contentController.clear(); // Clear the text field's controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity, // Set the desired width
                  height: 200, // Set the desired height
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    maxLength: 300,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp(r'[\n\r]')), // Disallow new lines
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: InputBorder.none, // Remove the border
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      if (value.length > 300) {
                        return 'Content cannot exceed 300 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
