//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//Providers
import '../../providers/authentication_provider.dart';
import '../../providers/explorer_page_provider.dart';
//Models
import '../../models/post.dart';
//Pages
import '../../pages/posts/post_page.dart';
//Widgets
import '../../widgets/custom_list_view_tiles.dart';
//Dialogs
import '../../pages/posts/create_post.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PostsPageState();
  }
}

class _PostsPageState extends State<PostsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ExplorerPageProvider _pageProvider;

  late ScrollController _postsListViewController;

  String postContent = ''; // Variable to hold the post content
  String selectedSort =
      'Newest'; // Variable to hold the selected sorting option

  @override
  void initState() {
    super.initState();

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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildSortButton('Newest'),
                              const SizedBox(width: 10),
                              _buildSortButton('Oldest'),
                              Expanded(
                                child: TextButton(
                                    onPressed: _openCreatePostDialog,
                                    child: Text('Create Post')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _postsListView(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortButton(String sortOption) {
    final isSelected = selectedSort == sortOption;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedSort = sortOption;
        });
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (isSelected) {
              return Colors.blue;
            }
            return Colors.white;
          },
        ),
      ),
      child: Text(
        sortOption,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _postsListView() {
    if (_pageProvider.posts != null) {
      if (_pageProvider.posts!.isNotEmpty) {
        List<Post> sortedPosts = _sortPosts(_pageProvider.posts!,
            selectedSort); // Sort the posts based on the selected sort option

        return SizedBox(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            itemCount: sortedPosts.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = sortedPosts[index];
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

  List<Post> _sortPosts(List<Post> posts, String sortOption) {
    if (sortOption == 'Newest') {
      return posts.reversed
          .toList(); // Sort by the newest posts (reverse order)
    } else {
      return posts; // No need to modify the order, as the posts are already in chronological order
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
