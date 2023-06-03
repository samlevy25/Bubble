import 'package:flutter/material.dart';
import '../../models/bubble.dart';
import 'Edit_bubble.dart';

class BubbleDetailsPage extends StatefulWidget {
  final Bubble bubble;

  const BubbleDetailsPage({Key? key, required this.bubble}) : super(key: key);

  @override
  _BubbleDetailsPageState createState() => _BubbleDetailsPageState();
}

class _BubbleDetailsPageState extends State<BubbleDetailsPage> {
  String newName = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String newDescription = '';

  void showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Edit Bubble',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExpansionTile(
                title: const Text('Change Name'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            newName = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 21, 0, 255),
                          ),
                          focusColor: const Color.fromARGB(255, 21, 0, 255),
                          filled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
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
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Perform save operation here
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Change Description'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          newDescription = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Description',
                      ),
                    ),
                  ),
                ],
              ),
              const ExpansionTile(
                title: Text('Delete Bubble'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage:
                            NetworkImage(widget.bubble.getImageURL()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.bubble.getName(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.bubble.getDescription(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return EditPage(
                          bubble: widget.bubble,
                        );
                      },
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
