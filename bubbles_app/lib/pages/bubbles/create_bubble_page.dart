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
import 'package:url_launcher/url_launcher.dart';

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
import "../../pages/bubbles/password_for_bubble.dart";

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
  bool visible = false;

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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.lightBlue,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.lightBlue,
              size: 30.0,
            ),
            onPressed: () async {
              final Uri _url =
                  Uri.parse('https://bubbles-website-716a4.web.app/');
              if (!await launchUrl(_url)) {
                throw Exception('Could not launch $_url');
              }
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceHeight * 0.03,
            vertical: _deviceHeight * 0.01,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.02),
                  child: _bubbleImageField(),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.02),
                  child: _bubbleForms(),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.01),
                  child: _sizeSelector(),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.03),
                  child: _keyTypeSelector(),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.03),
                  child: dataDisplay(),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: _deviceHeight * 0.03),
                  child: _createButton(),
                ),
              ],
            ),
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
      child: Column(
        children: [
          _bubbleImage != null
              ? RoundedImageFile(
                  key: UniqueKey(),
                  image: _bubbleImage!,
                  size: _deviceHeight * 0.17,
                )
              : SizedBox(
                  width: 150.0, // Vous pouvez changer cette valeur
                  height: 150.0, // Vous pouvez changer cette valeur
                  child: Image.asset("assets/images/addPhoto.png"),
                ),
          SizedBox(height: _deviceHeight * 0.01),
          Visibility(
            visible: visible,
            child: Text(
              "Please select the bubble's image.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[(700)],
              ),
            ),
          ),
        ],
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
              height: _deviceHeight * 0.02,
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
    bool isCreatingBubble = false;
    visible = false;
    // Flag to track creation process

    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(Size(350, 50)),
        backgroundColor: MaterialStateProperty.all<Color>(
            Colors.white), // Background color of the button
        foregroundColor: MaterialStateProperty.all<Color>(
            Colors.lightBlue), // Text color of the button
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Rounded border of the button
            side: BorderSide(
              color: Colors.lightBlue, // Border color of the button
              width: 1.5, // Adjust the width as needed
            ), // Border color of the button
          ),
        ),
      ),
      child: Text(
        "Create",
        style: TextStyle(
          fontSize: 30.0, // Text size of the button
          fontWeight: FontWeight.normal, // Text weight of the button
          // You can adjust the text scale factor here
        ),
      ),
      onPressed: () async {
        if (_bubbleImage == null) {
          setState(() {
            visible = true; // Set flag to indicate creation process
          });
        }

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
            String locationName = await getCurrentLocationName();
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
              locationName: locationName,
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
                  locationName: locationName,
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

  Widget _keyTypeSelector() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Access technologies",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black45,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: _deviceHeight * 0.03,
        ),
        Row(
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
        ),
      ],
    );
  }

  Widget _sizeSelector() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Range",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black45,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: _deviceHeight * 0.01),
        Slider(
          value: _bubbleSize!.toDouble(),
          min: 5,
          max: 8,
          divisions: 3,
          onChanged: (double value) {
            setState(() {
              _bubbleSize = value.round();
            });
          },
          label: BubbleSize.getNameByIndex(_bubbleSize!),
        ),
      ],
    );
  }

  // This widget displays current data: location, wifi, and key type
  Widget dataDisplay() {
    return SizedBox(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Your location",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black45,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: _deviceHeight * 0.02,
          ),
          Center(child: currentLocation()),
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
            '${snapshot.data}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
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
    print("WiFi BSSID: $bubbleKey");
    setState(() {
      _bubbleKeyType = BubbleKeyType.wifi;
    });
  }

  Future<void> _handlePassword() async {
    String? password = await showPasswordDialog(context, true);

    if (password != null) {
      setState(() {
        _bubbleKeyType = BubbleKeyType.password;
        bubbleKey = password;
      });
    }
  }

// Function to handle NFC selection
  Future<void> _handleNFC() async {
    bubbleKey = await NFCReader.readNfc(context);
    setState(() {
      _bubbleKeyType = BubbleKeyType.nfc;
    });
  }

// Function to handle Bluetooth selection
  Future<void> _handleBluetooth() async {
    bubbleKey = await Bluetooth.scanAndConnect(context);
    setState(() {
      _bubbleKeyType = BubbleKeyType.bluetooth;
    });
  }
}
