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

enum JoinMethod {
  gps,
  wifi,
  nfc,
}

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

  String? _name;
  JoinMethod? _selectedJoinMethod;
  String? JoinValue;
  int? _selected = 0;

  PlatformFile? _bubbleImage;

  final _registerFormKey = GlobalKey<FormState>();

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
            SizedBox(height: _deviceHeight * 0.05),
            _registerForm(),
            SizedBox(height: _deviceHeight * 0.05),
            joinInMethods(),
            SizedBox(height: _deviceHeight * 0.05),
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
            bubbleUid,
            createrUid,
            _name!,
            imageURL!,
          );
          navigation.goBack();
          navigation.navigateToPage(
            BubblePage(
              bubble: Bubble(
                currentUserUid: createrUid,
                uid: bubbleUid,
                name: _name!,
                members: [_auth.appUser],
                image: imageURL,
                geoPoint: GeoPoint(0, 0),
                messages: [],
              ),
            ),
          );
        }
      },
    );
  }

  Widget joinInMethods() {
    return Row(
      children: [
        _methodButton(index: 0, icon: Icons.gps_fixed),
        _methodButton(index: 1, icon: Icons.wifi),
        _methodButton(index: 2, icon: Icons.nfc),
      ],
    );
  }

  Widget _methodButton({required int index, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.all(_deviceWidth * 0.11),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selected == index ? Colors.white : null,
            ),
          ],
        ),
        onTap: () => setState(
          () {
            _selected = index;
          },
        ),
      ),
    );
  }
}
