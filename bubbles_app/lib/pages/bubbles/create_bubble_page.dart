// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/constants/bubble_sizes.dart';
import 'package:bubbles_app/networks/nfc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:get_it/get_it.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../../networks/bluetooth.dart';
import '../../networks/gps.dart';
import '../../networks/wifi.dart';

import '../../models/bubble.dart';

import '../../services/media_service.dart';
import '../../services/database_service.dart';
import '../../services/cloud_storage_service.dart';
import '../../services/navigation_service.dart';

import '../../widgets/custom_input_fields.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_radio_button.dart';
import '../../widgets/rounded_image.dart';

import '../../providers/authentication_provider.dart';
import 'bubble_page.dart';

import '../../constants/bubble_key_types.dart';

class CreateBubblePage extends StatefulWidget {
  const CreateBubblePage({Key? key}) : super(key: key);

  @override
  State<CreateBubblePage> createState() => _CreateBubblePageState();
}

class _CreateBubblePageState extends State<CreateBubblePage> {
  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService navigation;
  late double _deviceHeight;
  late double _deviceWidth;

  final _registerFormKey = GlobalKey<FormState>();

  PlatformFile? _bubbleImage;
  String? _bubbleName;
  String? _bubbleDescription;
  int? _bubbleSize = BubbleSize.medium.index;
  BubbleKeyType _bubbleKeyType = BubbleKeyType.gps;
  String? bubbleKey;

  // This widget builds the UI for the page
  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceHeight * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: _bubbleImageField(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: _bubbleForms(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: _sizeSelector(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: _keyTypeSelector(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: bubbleInfoWidget(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: _createButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This widget handles the selection of the image for the bubble
  Widget _bubbleImageField() {
    return GestureDetector(
      onTap: () async {
        var file =
            await GetIt.instance.get<MediaService>().pickedImageFromLibary();
        if (file != null) {
          setState(() {
            _bubbleImage = file;
          });
        }
      },
      child: _bubbleImage != null
          ? RoundedImageFile(
              key: UniqueKey(),
              image: _bubbleImage!,
              size: _deviceHeight * 0.15,
            )
          : RoundedImageNetwork(
              key: UniqueKey(),
              imagePath:
                  "https://firebasestorage.googleapis.com/v0/b/bubbles-96944.appspot.com/o/gui%2Fno_bubble_image.jpg?alt=media&token=dc17ae3f-e589-482c-b88c-81b4c9cb09b1",
              size: _deviceHeight * 0.15,
            ),
    );
  }

  // This widget provides the form to enter the bubble's name
  Widget _bubbleForms() {
    return SizedBox(
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              onSaved: (value) => setState(() => _bubbleName = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the bubble's name.";
                }
                if (!RegExp(r'.{8,}').hasMatch(value)) {
                  return "The bubble's name must have at least 8 characters.";
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.chat_bubble_outline),
                labelStyle: const TextStyle(
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
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Name",
              ),
            ),
            SizedBox(
              height: _deviceHeight * 0.01,
            ),
            TextFormField(
              onSaved: (value) => setState(() => _bubbleDescription = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the bubble's description.";
                }
                if (!RegExp(r'.{8,}').hasMatch(value)) {
                  return "The bubble's description must have at least 8 characters.";
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.description_outlined),
                labelStyle: const TextStyle(
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
                  borderSide: const BorderSide(
                    color: Colors.lightBlue,
                  ),
                ),
                labelText: "Description",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButton() {
    bool isCreatingBubble = false; // Flag to track creation process

    return ElevatedButton(
      child: const Text("Create"),
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() &&
            _bubbleImage != null &&
            !isCreatingBubble) {
          _registerFormKey.currentState!.save();
          print("condition met"); // Print statement added
          // Call a function to handle the selected key type.

          setState(() {
            isCreatingBubble = true; // Set flag to indicate creation process
          });

          print("Creating Bubble..."); // Print statement added

          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissal by tapping outside
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false, // Disable back button
                child: Dialog(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Creating Bubble..."),
                        SizedBox(height: 16.0),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

          try {
            print("user uid: ${_auth.appUser.uid}"); // Print statement added
            String createrUid = _auth.appUser.uid;
            print("generating bubble uid..."); // Print statement added
            String bubbleUid = _db.generateBubbleUid();
            print("getting location..."); // Print statement added
            String location = await getCurrentGeoHash(_bubbleSize!);
            GeoPoint geoPoint = await getCurrentGeoPoint(22);
            print("saving image to storage..."); // Print statement added
            String? imageURL = await _cloudStorage.saveBubbleImageToStorage(
              bubbleUid,
              _bubbleImage!,
            );

            // Get the description and topics from the respective form fields
            String? description = _bubbleDescription;

            print("Creating Bubble..."); // Print statement added
            await _db.createBubble(
              bubbleUid: bubbleUid,
              createrUid: createrUid,
              name: _bubbleName!,
              imageURL: imageURL!,
              keyType: _bubbleKeyType.index,
              key: bubbleKey,
              geohash: location,
              geoPoint: geoPoint,
              description: description,
              bubbleSize: _bubbleSize!,
            );

            print("Bubble created successfully"); // Print statement added

            navigation.goBack();

            // Navigate to the bubble page
            navigation.goBack();
            BubblePage(
              bubble: Bubble(
                  currentUserUid: createrUid,
                  admin: createrUid,
                  uid: bubbleUid,
                  name: _bubbleName!,
                  image: imageURL,
                  messages: [],
                  keyType: _bubbleKeyType,
                  key: bubbleKey,
                  geohash: location,
                  description: description!,
                  geoPoint: geoPoint,
                  size: _bubbleSize!),
            );
          } catch (error) {
            // Handle any errors that occur during bubble creation
            print("Error creating bubble: $error");
            // TODO: Handle error state
          } finally {
            // ...
          }
        }
      },
    );
  }

// Function to handle different BubbleKeyType selections
  void _handleBubbleKeyType(BubbleKeyType selectedKeyType) async {
    switch (selectedKeyType) {
      case BubbleKeyType.gps:
        await _handleGPS();
        break;
      case BubbleKeyType.wifi:
        await _handleWiFi();
        break;
      case BubbleKeyType.nfc:
        _handleNFC();
        break;
      case BubbleKeyType.password:
        await _handlePassword();
        break;
      case BubbleKeyType.bluetooth:
        _handleBluetooth();
        break;
    }
  }

  // This widget allows the user to select the bubble's access method
// This widget allows the user to select the bubble's access method
// This widget allows the user to select the bubble's access method
  Widget _keyTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: BubbleKeyType.values.map((BubbleKeyType type) {
        return Column(
          children: [
            InkWell(
              onTap: () => _handleBubbleKeyType(type),
              child: Icon(
                type.icon,
                size: 24.0,
                color: _bubbleKeyType == type ? Colors.blue : Colors.grey,
              ),
            ),
            Text(
              type.name,
              textAlign: TextAlign.center,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _sizeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: BubbleSize.values.map((BubbleSize size) {
        final isSelected = _bubbleSize == size.index;
        return Expanded(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _bubbleSize = size.index;
                  });
                },
                child: Text(
                  size.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget bubbleInfoWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        border: Border.all(
          color: Colors.lightBlue,
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Your information',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            dataDisplay(),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                'Technologies access bubble',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16.0),
                children: const [
                  TextSpan(
                    text: 'GPS',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Bubble located within the same perimeter.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17.0),
                children: const [
                  TextSpan(
                    text: 'WIFI',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Only users with the same WIFI connection.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17.0),
                children: const [
                  TextSpan(
                    text: 'NFC',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Allows you to access the Bubble using the corresponding NFC card.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17.0),
                children: const [
                  TextSpan(
                    text: 'Password',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'The password for the Bubble is required for entry.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This widget displays current data: location, wifi, and key type
  Widget dataDisplay() {
    return SizedBox(
      child: Column(
        children: [
          Center(child: currentLocation()),
          SizedBox(height: 10.0),
          Center(child: currentWIFI()),
        ],
      ),
    );
  }

  // This widget fetches and displays the current location
  FutureBuilder<String> currentLocation() {
    return FutureBuilder<String>(
      future: getCurrentLocationName(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text(
            'Location: ${snapshot.data}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          );
        }
      },
    );
  }

  // This widget fetches and displays the current WIFI name
  FutureBuilder<String> currentWIFI() {
    return FutureBuilder<String>(
      future: getWifiName().then((p) => p.toString()),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text(
            'WIFI: ${snapshot.data}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          );
        }
      },
    );
  }

  // This widget displays the selected bubble key type
  Widget currentKey() {
    return Text(_bubbleKeyType.name);
  }

  // Function to handle GPS selection
  Future<void> _handleGPS() async {
    bubbleKey = await getCurrentGeoHash(22);
    setState(() {
      _bubbleKeyType = BubbleKeyType.gps;
    });
  }

// Function to handle WiFi selection
  Future<void> _handleWiFi() async {
    bubbleKey = await getWifiBSSID();
    setState(() {
      _bubbleKeyType = BubbleKeyType.wifi;
    });
  }

  Future<void> _handlePassword() async {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    String? passwordError;

    String? password = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      errorText: passwordError,
                    ),
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String? password = passwordController.text;
                    String? confirmPassword = confirmPasswordController.text;

                    if (password != null &&
                        confirmPassword != null &&
                        password.length >= 8 &&
                        password == confirmPassword) {
                      Navigator.of(context).pop(password);
                    } else {
                      setState(() {
                        passwordError =
                            "Passwords do not match \nor are less than 8 characters long";
                      });
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (password != null) {
      setState(() {
        _bubbleKeyType = BubbleKeyType.password;
        bubbleKey = password;
      });

      // Perform further operations with the password...
    }
  }

// Function to handle NFC selection
  Future<String?> _handleNFC() async {
    setState(() {
      _bubbleKeyType = BubbleKeyType.nfc;
    });
    print("Starting NFC reader...");
  }

// Function to handle Bluetooth selection
  void _handleBluetooth() {
    setState(() {
      _bubbleKeyType = BubbleKeyType.bluetooth;
    });
  }
}
