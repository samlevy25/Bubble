import 'package:bubbles_app/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';
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

  String? _bubbleName;
  PlatformFile? _bubbleImage;
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

  // This method constructs the UI
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _bubbleImageField(),
            _nameForm(),
            dataDisplay(),
            _methodsSelector(),
            _createButton(),
          ],
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
  Widget _nameForm() {
    return SizedBox(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (value) => setState(() => _bubbleName = value),
              regEx: r'.{8,}',
              hintText: "Bubble's Name",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }

  // This widget creates the bubble when all the fields are validated
  Widget _createButton() {
    return RoundedButton(
      name: "Create",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() && _bubbleImage != null) {
          _registerFormKey.currentState!.save();
          // Call a function to handle the selected key type.

          String createrUid = _auth.appUser.uid;
          String bubbleUid = _db.generateBubbleUid();
          String location = await getCurrentGeoHash(22);
          String? imageURL = await _cloudStorage.saveBubbleImageToStorage(
            bubbleUid,
            _bubbleImage!,
          );

          await _db.createBubble(
            bubbleUid: bubbleUid,
            createrUid: createrUid,
            name: _bubbleName!,
            imageURL: imageURL!,
            keyType: _bubbleKeyType.index,
            key: bubbleKey,
            geohash: location,
          );
          navigation.goBack();

          navigation.navigateToPage(
            BubblePage(
              bubble: Bubble(
                  currentUserUid: createrUid,
                  admin: createrUid,
                  uid: bubbleUid,
                  name: _bubbleName!,
                  members: [_auth.appUser],
                  image: imageURL,
                  messages: [],
                  keyType: _bubbleKeyType,
                  key: bubbleKey,
                  geohash: location),
            ),
          );
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
  Widget _methodsSelector() {
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

  // This widget displays current data: location, wifi, and key type
  Widget dataDisplay() {
    return SizedBox(
      width: _deviceWidth,
      height: _deviceHeight * 0.1,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          children: [
            currentLocation(),
            currentKey(),
            currentWIFI(),
          ],
        ),
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
          return Text('Location: ${snapshot.data}');
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
          return Text('WIFI: ${snapshot.data}');
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
    String? nfcKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // Replace this with your NFC selection dialog
        return AlertDialog(
          title: Text("Select NFC Key"),
          content: Column(
            children: [
              // NFC key selection options
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle the selection and return the NFC key
                // Example: String nfcKey = getSelectedNFCKey();
                Navigator.of(context).pop(null);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (nfcKey != null) {
      setState(() {
        _bubbleKeyType = BubbleKeyType.nfc;
        bubbleKey = nfcKey;
      });

      // Perform further operations with the NFC key...
    }

    return nfcKey;
  }

// Function to handle Bluetooth selection
  void _handleBluetooth() {
    getConnectedDevices().then((List<BluetoothDevice> devices) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Bluetooth Device'),
            content: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothDevice device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  onTap: () {
                    Navigator.pop(context, device);
                  },
                );
              },
            ),
          );
        },
      ).then((selectedDevice) {
        if (selectedDevice != null) {
          setState(() {
            _bubbleKeyType = BubbleKeyType.bluetooth;
            // _selectedDevice = selectedDevice;
          });
        }
      });
    });
  }
}
