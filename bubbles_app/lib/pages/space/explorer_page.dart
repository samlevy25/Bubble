import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/authentication_provider.dart';
import '../../providers/explorer_page_provider.dart';
import '../../widgets/post_text_form_fied.dart';
import '../../models/post.dart';
import '../../pages/space/post_page.dart';
import '../../widgets/custom_list_view_tiles.dart';
import 'create_post.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExplorerPageState();
  }
}

class _ExplorerPageState extends State<ExplorerPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ExplorerPageProvider _pageProvider;

  late GlobalKey<FormState> _postFormState;
  late ScrollController _postsListViewController;

  String postContent = ''; // Variable to hold the post content

  @override
  void initState() {
    super.initState();
    _postFormState = GlobalKey<FormState>();
    _postsListViewController = ScrollController();
  }

  void createPost(String content) {
    setState(() {
      postContent = content; // Update the post content in the state
    });
    _pageProvider.post = postContent; // Update the post content in the provider
    _pageProvider.sendTextPost(); // Send the post to the database
    print('Created Post: $postContent');
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExplorerPageProvider>(
          create: (_) => ExplorerPageProvider(_auth, _postsListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ExplorerPageProvider>();
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _deviceWidth * 0.03,
                        vertical: _deviceHeight * 0.02,
                      ),
                      child: _postsListView(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreatePostDialog,
            icon: const Icon(Icons.add),
            label: const Text("Create Post"),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _postsListView() {
    if (_pageProvider.posts != null) {
      if (_pageProvider.posts!.isNotEmpty) {
        return SizedBox(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            itemCount: _pageProvider.posts!.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = _pageProvider.posts![index];
              bool isOwnMessage = post.sender == _auth.appUser;
              return GestureDetector(
                child: CustomExplorerListViewTile(
                  deviceHeight: _deviceHeight,
                  width: _deviceWidth * 0.80,
                  post: post,
                  isOwnMessage: isOwnMessage,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(post: post),
                    ),
                  );
                },
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

  void _openCreatePostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreatePostDialog(
          onPostCreated: createPost,
        );
      },
    );
  }
}
