//Packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../providers/authentication_provider.dart';
import '../../providers/chat_page_provider.dart';
import '../../widgets/custom_input_fields.dart';
import '../../widgets/custom_list_view_tiles.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  //add function here to delete chat

  const ChatPage({super.key, required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              widget.chat.uid, _auth, _messagesListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatPageProvider>();
        return Scaffold(
            appBar: AppBar(
              title: const Text('Private Chat'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Supprimer la conversation',
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        content: const Text(
                          'Are you sure you want to delete the chat?',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Alignement des éléments au centre
                            children: <Widget>[
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'No',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      20), // Vous pouvez ajuster cet espace selon vos préférences
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Yes, I'm sure",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
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
                  child: sendMessageForm(),
                ),
              ],
            ));
      },
    );
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return SizedBox(
          height: _deviceHeight * 0.78,
          child: ListView.builder(
            controller: _messagesListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext context, int index) {
              Message message = _pageProvider.messages![index];
              bool isOwnMessage = message.sender == _auth.appUser;
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
            style: TextStyle(color: Colors.lightBlue),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue,
        ),
      );
    }
  }

  Widget sendMessageForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Form(
        key: _messageFormState,
        child: TextFormField(
          onSaved: (value) {
            _pageProvider.message = value!;
          },
          decoration: InputDecoration(
            fillColor: const Color.fromARGB(255, 255, 255, 255),
            filled: true,
            hintText: "Message",
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(100.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 0.7),
              borderRadius: BorderRadius.circular(100.0),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    _pageProvider.sendImageMessage();
                  },
                  icon: const Icon(Icons.photo_camera),
                  color: Colors.lightBlue,
                ),
                IconButton(
                  onPressed: () {
                    if (_messageFormState.currentState!.validate()) {
                      _messageFormState.currentState!.save();
                      _pageProvider.sendTextMessage();
                      _messageFormState.currentState!.reset();
                    }
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.lightBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
