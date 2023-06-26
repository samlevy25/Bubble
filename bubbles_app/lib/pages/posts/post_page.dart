import 'package:bubbles_app/models/comment.dart';
import 'package:bubbles_app/providers/authentication_provider.dart';
import 'package:bubbles_app/services/database_service.dart';
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../widgets/custom_list_view_tiles.dart';

//Packages
import 'package:timeago/timeago.dart' as timeago;

import '../../widgets/pop_up_menu.dart';

enum SortBy { newest, oldest }

class PostPage extends StatefulWidget {
  final String postUid;
  late Post post;

  PostPage({Key? key, required this.postUid}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  Post? post;
  SortBy _sortBy = SortBy.newest;

  late DatabaseService _db;
  late AuthenticationProvider _auth;
  late AppUser user;
  late bool _isLoading;

  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _db = GetIt.instance.get<DatabaseService>();
    _isLoading = true;
    _commentController = TextEditingController();
    initializePost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void initializePost() {
    _db.getPost(widget.postUid).then((retrievedPost) {
      if (retrievedPost != null) {
        setState(() {
          post = retrievedPost;
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print("Post not found");
        }
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((e) {
      if (kDebugMode) {
        print("Error retrieving post");
        print(e);
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _sortComments(SortBy sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (_sortBy) {
        case SortBy.newest:
          post?.comments.sort((a, b) => b.sentTime.compareTo(a.sentTime));
          break;
        case SortBy.oldest:
          post?.comments.sort((a, b) => a.sentTime.compareTo(b.sentTime));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _db = GetIt.instance.get<DatabaseService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    user = _auth.appUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("${_auth.appUser.username}'s post"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _deviceHeight * 0.02),
                GestureDetector(
                  child: CustomExplorerListViewTile(
                    deviceHeight: _deviceHeight,
                    width: _deviceWidth * 0.80,
                    post: post!,
                    isOwnMessage: true,
                    actions: true,
                  ),
                  onLongPress: () {
                    PopupMenu.showUserDetails(
                        context, _auth.appUser, post!.sender);
                  },
                ),
                _rates(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildSortButton(SortBy.newest),
                    const SizedBox(width: 10),
                    _buildSortButton(SortBy.oldest),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _showCommentPopup(context);
                        },
                        child: const Text('Comment'),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: post?.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post?.comments[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: _db.getUser(comment!.senderID),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.data() != null) {
                            // Retrieve commenter data from snapshot
                            Map<String, dynamic> userData =
                                snapshot.data?.data() as Map<String, dynamic>;
                            userData["uid"] = comment.senderID;
                            final commenter = AppUser.fromJSON(userData);
                            commenter;

                            return GestureDetector(
                              child: ListTile(
                                leading: RoundedImageNetwork(
                                  key: UniqueKey(),
                                  imagePath: commenter.imageURL,
                                  size: _deviceWidth * 0.08,
                                ),
                                title: Column(
                                  // mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          commenter.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.star,
                                          size: 15,
                                          color:
                                              Color.fromARGB(255, 255, 162, 0),
                                        ),
                                        Text(comment.votesUp.toString()),
                                        IconButton(
                                          onPressed: () {
                                            _addVoteToComment(
                                                comment.uid, 1); // Upvote
                                          },
                                          icon: const Icon(Icons.thumb_up),
                                          iconSize: 15,
                                          color: Colors.lightBlue,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _addVoteToComment(
                                                comment.uid, -1); // Downvote
                                          },
                                          icon: const Icon(Icons.thumb_down),
                                          iconSize: 15,
                                          color: Colors.lightBlue,
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                        color: Colors
                                            .grey), // This adds a horizontal line
                                  ],
                                ),
                                subtitle: Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.content,
                                        style: const TextStyle(
                                            fontSize: 17, color: Colors.black),
                                      ),
                                      SizedBox(height: _deviceHeight * 0.006),
                                      Text(
                                        timeago.format(comment.sentTime),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black38),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onLongPress: () {
                                PopupMenu.showUserDetails(
                                    context, _auth.appUser, commenter);
                              },
                            );
                          } else if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSortButton(SortBy sortOption) {
    final isSelected = _sortBy == sortOption;

    return ElevatedButton(
      onPressed: () => _sortComments(sortOption),
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
            } else {
              return Colors.white;
            }
          },
        ),
      ),
      child: Text(
        sortOption == SortBy.newest ? 'Newest' : 'Oldest',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _rates() {
    int totalVotes = post!.votesUp + post!.votesDown;
    double goodRate =
        totalVotes != 0 ? (post!.votesUp / totalVotes) * 100 : 0.0;
    double badRate =
        totalVotes != 0 ? (post!.votesDown / totalVotes) * 100 : 0.0;
    bool isGood = goodRate >= badRate;
    double rate = isGood ? goodRate : badRate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange),
            const SizedBox(width: 5),
            Text(
              '${double.parse(rate.toStringAsFixed(2))}%',
              style: TextStyle(
                color: isGood ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.remove_red_eye, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              '$totalVotes',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _db.addVoteToPost(post!.uid, user.uid, 1);
                  print("Liked");
                  _refreshPost();
                });
              },
              icon: const Icon(Icons.thumb_up),
              color: Colors.lightBlue,
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  _db.addVoteToPost(post!.uid, user.uid, -1);
                  print("Disliked");
                  _refreshPost();
                });
              },
              icon: const Icon(Icons.thumb_down),
              color: Colors.lightBlue,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final commentContent = _commentController.text.trim();
      final uid = _db.generateCommentUid(post!.uid);
      final comment = Comment(
        uid: uid,
        content: commentContent,
        senderID: user.uid,
        sentTime: DateTime.now(),
        type: CommentType.text,
        voters: [],
        votesUp: 0,
        votesDown: 0,
      );

      await _db.addCommentToPost(post!.uid, uid, comment);

      // Clear the comment text field
      _commentController.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Error adding comment: $e");
      }
    }
  }

  void _showCommentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Write a Comment'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Enter your comment...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addComment();
                Navigator.of(context).pop();
                _refreshPost();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addVoteToComment(String commentUid, int voteValue) {
    _db.addVoteToComment(post!.uid, commentUid, user.uid, voteValue);
    _refreshPost();
  }

  Future<void> _refreshPost() async {
    final retrievedPost = await DatabaseService().getPost(widget.postUid);
    if (retrievedPost != null) {
      setState(() {
        post = retrievedPost;
      });
    }
  }
}
