// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../models/bubble.dart';

class EditPage extends StatefulWidget {
  final Bubble bubble;

  EditPage({required this.bubble});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  String newName = '';

  final GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  String newDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bubble'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Text(
                'Change Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                SizedBox(height: 16.0),
                Form(
                  key: nameFormKey,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        newName = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 21, 0, 255),
                      ),
                      focusColor: Color.fromARGB(255, 21, 0, 255),
                      filled: true,
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 21, 0, 255),
                        ),
                      ),
                      labelText: "New Name",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name.';
                      }
                      if (!RegExp(r'.{8,}').hasMatch(value)) {
                        return 'Name must be at least 8 characters long.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (nameFormKey.currentState!.validate()) {
                      widget.bubble.updateBubbleName(newName);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Change Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                SizedBox(height: 16.0),
                Form(
                  key: descriptionFormKey,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        newDescription = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 21, 0, 255),
                      ),
                      focusColor: Color.fromARGB(255, 21, 0, 255),
                      filled: true,
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 21, 0, 255),
                        ),
                      ),
                      labelText: "New Description",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description.';
                      }
                      if (!RegExp(r'.{8,}').hasMatch(value)) {
                        return 'Description must be at least 8 characters long.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (descriptionFormKey.currentState!.validate()) {
                      widget.bubble.updateBubbleDescription(newDescription);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Delete Bubble',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Text(
                  'Are you sure you want to delete this bubble ?',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.bubble.deleteBubble();
                      },
                      child: Text('Yes, I\'m sure'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
