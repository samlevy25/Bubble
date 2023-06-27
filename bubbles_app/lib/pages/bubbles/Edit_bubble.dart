// ignore_for_file: prefer_const_constructors
import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/services/automated_dbms_api.dart';
import 'package:bubbles_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../models/bubble.dart';
import '../../providers/authentication_provider.dart';

class EditPage extends StatefulWidget {
  final Bubble bubble;

  EditPage({required this.bubble});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  String newName = '';
  late double _deviceHeight;
  bool isNameChanged = false;
  bool isDescriptionChanged = false;
  bool isBubbleRemove = false;
  final DatabaseService _db = GetIt.instance.get<DatabaseService>();

  late AuthenticationProvider _auth;

  final GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  String newDescription = '';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Edit Bubble'),
          backgroundColor:
              BubbleKeyType.getColorByIndex(widget.bubble.keyType.index)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Aligne les enfants horizontalement au centre
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.01),
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(widget.bubble.getImageURL()),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: _deviceHeight * 0.01),
              child: Text(
                widget.bubble.getName(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: _deviceHeight * 0.02),
              child: Text(
                widget.bubble.getDescription(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            ExpansionTile(
              title: Text(
                'Change Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                SizedBox(height: _deviceHeight * 0.005),
                Form(
                  key: nameFormKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isNameChanged
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: _deviceHeight * 0.0241),
                              child: const Text(
                                "Profile image changed successfully.",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                key: Key('imagage changed'),
                              ),
                            ),
                          )
                        : TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newName = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color: Colors.lightBlue,
                              ),
                              focusColor: Colors.lightBlue,
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.lightBlue,
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
                SizedBox(height: _deviceHeight * 0.01),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isNameChanged = false;
                    });

                    if (widget.bubble.admin != _auth.appUser.uid) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(
                                  15.0), // Customize your padding here
                              child: Text(
                                'Only admin can change name bubble',
                                textAlign: TextAlign
                                    .center, // This will center your text.
                                style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold, // For making the text bold
                                  color: Colors.red, // For making the text red
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      if (nameFormKey.currentState!.validate()) {
                        setState(() {
                          isNameChanged = true;
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            isNameChanged = false;
                          });
                        });
                        widget.bubble.updateBubbleName(newName);
                      }
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
                SizedBox(height: _deviceHeight * 0.005),
                Form(
                  key: descriptionFormKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isDescriptionChanged
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: _deviceHeight * 0.0241),
                              child: const Text(
                                "Profile image changed successfully.",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                key: Key('imagage changed'),
                              ),
                            ),
                          )
                        : TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newDescription = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color: Colors.lightBlue,
                              ),
                              focusColor: Colors.lightBlue,
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.lightBlue,
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
                ),
                SizedBox(height: _deviceHeight * 0.01),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isDescriptionChanged = false;
                    });
                    if (widget.bubble.admin != _auth.appUser.uid) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(
                                  17.0), // Customize your padding here
                              child: Text(
                                'Only admin can change description bubble',
                                style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold, // For making the text bold
                                  color: Colors.red,
                                  fontSize: 15, // For making the text red
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      if (descriptionFormKey.currentState!.validate()) {
                        setState(() {
                          isDescriptionChanged = true;
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            isDescriptionChanged = false;
                          });
                        });

                        widget.bubble.updateBubbleDescription(newDescription);
                      }
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isBubbleRemove
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: _deviceHeight * 0.0025),
                            child: const Text(
                              "Bubble has been successfully deleted.",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              key: Key('image changed'),
                            ),
                          ),
                        )
                      : Text(
                          'Are you sure you want to delete this bubble ?',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                ),
                SizedBox(height: _deviceHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDescriptionChanged = false;
                        });
                        if (widget.bubble.admin != _auth.appUser.uid) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      15.0), // Customize your padding here
                                  child: Text(
                                    'Only admin can remove bubble',
                                    textAlign: TextAlign
                                        .center, // This will center your text.
                                    style: TextStyle(
                                      fontWeight: FontWeight
                                          .bold, // For making the text bold
                                      color:
                                          Colors.red, // For making the text red
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          setState(() {
                            isBubbleRemove = true;
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              isBubbleRemove = false;
                            });
                          });
                          widget.bubble.deleteBubble();
                        }
                      },
                      child: Text('Yes, I\'m sure'),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
                onPressed: () {
                  AutomatedDBMSAPI.bubbleReq(widget.bubble.uid);
                },
                child: Text('Report Bubble')),
          ],
        ),
      ),
    );
  }
}
