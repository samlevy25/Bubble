// Packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Pages
import '../pages/bubble_page.dart';

//Networks
import '../networks/gps.dart';

//Models
import '../models/geohash.dart';
import '../models/bubble.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../widgets/custom_radio_button.dart';
import '../widgets/rounded_image.dart';

//Providers
import '../providers/authentication_provider.dart';

class CreateBubblePage extends StatefulWidget {
  const CreateBubblePage({super.key});

  @override
  State<CreateBubblePage> createState() => _CreateBubblePageState();
}

class _CreateBubblePageState extends State<CreateBubblePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService navigation;

  final _registerFormKey = GlobalKey<FormState>();

  String? _bubbleName;
  PlatformFile? _bubbleImage;
  int _bubbleRange = 5;
  int _bubbleKeyType = 0;

  final String _bubbleKey = "wifi/nfc";

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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _bubbleImageField(),
            _nameForm(),
            displayMethods(),
            _rangesSelector(),
            _methodsSelector(),
            _createButton(),
          ],
        ),
      ),
    );
  }

  Widget _bubbleImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickedImageFromLibary().then(
              (file) => {
                setState(
                  () {
                    _bubbleImage = file;
                  },
                )
              },
            );
      },
      child: () {
        if (_bubbleImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: _bubbleImage!,
            size: _deviceHeight * 0.15,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            imagePath:
                "https://firebasestorage.googleapis.com/v0/b/bubbles-96944.appspot.com/o/gui%2Fno_bubble_image.jpg?alt=media&token=dc17ae3f-e589-482c-b88c-81b4c9cb09b1",
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

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
            CustomTextFromField(
              onSaved: (value) {
                setState(() {
                  _bubbleName = value;
                });
              },
              regEx: r'.{8,}',
              hintText: "Bubble's Name",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButton() {
    return RoundedButton(
      name: "Create",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() && _bubbleImage != null) {
          _registerFormKey.currentState!.save();
          String createrUid = _auth.appUser.uid;
          String bubbleUid = _db.generateBubbleUid();
          GeoHash location = await determinePosition(_bubbleRange);
          String? imageURL = await _cloudStorage.saveBubbleImageToStorage(
            bubbleUid,
            _bubbleImage!,
          );

          await _db.createBubble(
            bubbleUid: bubbleUid,
            createrUid: createrUid,
            name: _bubbleName!,
            imageURL: imageURL!,
            methoudType: _bubbleKeyType,
            methodValue: _bubbleKey,
            location: location,
          );
          navigation.goBack();
          navigation.navigateToPage(
            BubblePage(
              bubble: Bubble(
                currentUserUid: createrUid,
                uid: bubbleUid,
                name: _bubbleName!,
                members: [_auth.appUser],
                image: imageURL,
                messages: [],
                methodType: _bubbleKeyType,
                methodValue: _bubbleKey,
                geoHash: location,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _methodsSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyRadioListTile(
              value: 0,
              groupValue: _bubbleKeyType,
              title: "GPS",
              onChanged: (value) => setState(() => _bubbleKeyType = value!),
              icon: Icons.gps_fixed,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: 1,
              groupValue: _bubbleKeyType,
              title: "WIFI",
              onChanged: (value) => setState(() => _bubbleKeyType = value!),
              icon: Icons.wifi,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: 2,
              groupValue: _bubbleKeyType,
              title: "NFC",
              onChanged: (value) => setState(() => _bubbleKeyType = value!),
              icon: Icons.nfc,
              width: _deviceWidth * 0.1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _rangesSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyRadioListTile(
              value: 8,
              groupValue: _bubbleRange,
              title: "House",
              onChanged: (value) => setState(() => _bubbleRange = value!),
              icon: Icons.house,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: 7,
              groupValue: _bubbleRange,
              title: "Bulding",
              onChanged: (value) => setState(() => _bubbleRange = value!),
              icon: Icons.location_city,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: 6,
              groupValue: _bubbleRange,
              title: "area",
              onChanged: (value) => setState(() => _bubbleRange = value!),
              icon: Icons.map,
              width: _deviceWidth * 0.1,
            ),
            MyRadioListTile(
              value: 5,
              groupValue: _bubbleRange,
              title: "big area",
              onChanged: (value) => setState(() => _bubbleRange = value!),
              icon: Icons.public,
              width: _deviceWidth * 0.1,
            ),
          ],
        ),
      ],
    );
  }

  Widget displayMethods() {
    return SizedBox(
      width: _deviceWidth,
      height: _deviceHeight * 0.1,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          children: [
            currentLocation(),
            currentKey(),
          ],
        ),
      ),
    );
  }

  Widget customRadioButton(int index, {String? text, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.all(_deviceWidth * 0.1),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _bubbleKeyType == index ? Colors.red : null,
            ),
            Text(
              text!,
              style: TextStyle(
                color: _bubbleKeyType == index ? Colors.red : null,
              ),
            ),
          ],
        ),
        onTap: () => setState(
          () {
            _bubbleKeyType = index;
          },
        ),
      ),
    );
  }

  FutureBuilder<String> currentLocation() {
    return FutureBuilder<String>(
      future: determinePosition(_bubbleRange).then((p) => p.toString()),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading...');
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('Result: ${snapshot.data}');
            }
        }
      },
    );
  }

  Widget currentKey() {
    return Text(_bubbleKeyType.toString());
  }
}
