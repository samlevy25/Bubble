// p
import 'package:bubbles_app/models/bubble.dart';
import 'package:bubbles_app/pages/bubble_page.dart';
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//s
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//w
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//pr
import '../providers/authentication_provider.dart';

//ex
import 'package:network_info_plus/network_info_plus.dart';

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

  String? _name;
  PlatformFile? _bubbleImage;
  int _methodType = 0;
  String? _methodValue;
  final GeoPoint _location = const GeoPoint(0, 0);

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
            SizedBox(height: _deviceHeight * 0.01),
            _registerForm(),
            SizedBox(height: _deviceHeight * 0.01),
            joinInMethods(),
            SizedBox(height: _deviceHeight * 0.01),
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

  Widget _registerForm() {
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
                  _name = value;
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

          String? imageURL = await _cloudStorage.saveBubbleImageToStorage(
            bubbleUid,
            _bubbleImage!,
          );
          await _db.createBubble(
            bubbleUid: bubbleUid,
            createrUid: createrUid,
            name: _name!,
            imageURL: imageURL!,
            methoudType: _methodType,
            methodValue: _methodValue,
            location: _location!,
          );
          navigation.goBack();
          navigation.navigateToPage(
            BubblePage(
              bubble: Bubble(
                currentUserUid: createrUid,
                uid: bubbleUid,
                name: _name!,
                members: [_auth.appUser],
                image: imageURL!,
                messages: [],
                methodType: _methodType,
                methodValue: _methodValue,
                location: _location,
              ),
            ),
          );
        }
      },
    );
  }

  joinInMethods() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _methodRadioButton(0, text: "GPS", icon: Icons.gps_fixed),
            _methodRadioButton(1, text: "WIFI", icon: Icons.wifi),
            _methodRadioButton(2, text: "NFC", icon: Icons.nfc),
          ],
        ),
        selectedMethod(),
      ],
    );
  }

  Widget selectedMethod() {
    return SizedBox(
      width: _deviceWidth,
      height: _deviceHeight * 0.1,
      child: const DecoratedBox(
        child: Text("HI"),
        decoration: BoxDecoration(color: Colors.blue),
      ),
    );
  }

  Widget _methodRadioButton(int index, {String? text, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.all(_deviceWidth * 0.1),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _methodType == index ? Colors.red : null,
            ),
            Text(
              text!,
              style: TextStyle(
                color: _methodType == index ? Colors.red : null,
              ),
            ),
          ],
        ),
        onTap: () => setState(
          () {
            _methodType = index;
            _methodValue = getMethodValue();
          },
        ),
      ),
    );
  }

  String? getMethodValue() {
    switch (_methodType) {
      case 0:
        return "location";
      case 1:
        return "networkName";
      case 2:
        return "nfcCode";
    }
    return null;
  }

  Widget gps() {
    return Container(
      child: Text("GPS"),
    );
  }
}
