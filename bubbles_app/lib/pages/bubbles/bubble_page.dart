//Packages
import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/models/activity.dart';
import 'package:bubbles_app/providers/bubble_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../../models/bubble.dart';
import '../../models/message.dart';
import '../../providers/authentication_provider.dart';
import '../../widgets/custom_input_fields.dart';
import '../../widgets/custom_list_view_tiles.dart';
import 'bubble_details.dart';

class BubblePage extends StatefulWidget {
  final Bubble bubble;

  const BubblePage({super.key, required this.bubble});

  @override
  State<StatefulWidget> createState() {
    return _BubblePageState();
  }
}

class _BubblePageState extends State<BubblePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late BubblePageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;

  void _openBubbleDetailsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).animate(animation),
            child: BubbleDetailsPage(bubble: widget.bubble),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);

    _auth.appUser.addActivity(Activity(
      "You joined ${widget.bubble.name}",
      DateTime.now(),
    ));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BubblePageProvider>(
          create: (_) => BubblePageProvider(
              widget.bubble.uid, _auth, _messagesListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<BubblePageProvider>();
        return Scaffold(
          appBar: AppBar(
            backgroundColor:
                BubbleKeyType.getColorByIndex(widget.bubble.keyType.index),
            title: Center(
              child: Row(
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.bubble.image)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _openBubbleDetailsPage();
                    },
                    child: Column(
                      children: [
                        Text(
                          widget.bubble.name,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          widget.bubble.description,
                          style: const TextStyle(
                              fontSize: 12.0, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                onPressed: () {
                  _pageProvider.deleteBubble();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  color:
                      BubbleKeyType.getColorByIndex(widget.bubble.keyType.index)
                          .withOpacity(0.05),
                  padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.03,
                    vertical: _deviceHeight * 0.02,
                  ),
                  height: _deviceHeight,
                  width: _deviceWidth * 0.97,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _messagesListView(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _sendMessageForm(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return SizedBox(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: _messagesListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext context, int index) {
              Message message = _pageProvider.messages![index];
              bool isOwnMessage = message.sender.uid == _auth.appUser.uid;
              return CustomChatListViewTile(
                deviceHeight: _deviceHeight,
                width: _deviceWidth * 0.80,
                message: message,
                isOwnMessage: isOwnMessage,
                sender: message.sender,
              );
            },
          ),
        );
      } else {
        return const Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first to say Hi!",
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sendMessageButton(),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
          onSaved: (value) {
            _pageProvider.message = value;
          },
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obscureText: false),
    );
  }

  Widget _sendMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: IconButton(
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _pageProvider.sendTextMessage();
            _messageFormState.currentState!.reset();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(
          0,
          82,
          218,
          1.0,
        ),
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
