import 'package:bubbles_app/models/comment.dart';
import 'package:bubbles_app/services/database_service.dart';
import 'package:bubbles_app/widgets/rounded_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../widgets/custom_list_view_tiles.dart';

//Packages
import 'package:timeago/timeago.dart' as timeago;

enum SortBy { newest, oldest }

class PostPage extends StatefulWidget {
  final Post post;

  PostPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late List<Comment> _comments;
  SortBy _sortBy = SortBy.newest;

  late DatabaseService _db;

  @override
  void initState() {
    _comments = widget.post.comments;
    super.initState();
  }

  void _sortComments(SortBy sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (_sortBy) {
        case SortBy.newest:
          _comments.sort((a, b) => b.sentTime.compareTo(a.sentTime));
          break;
        case SortBy.oldest:
          _comments.sort((a, b) => a.sentTime.compareTo(b.sentTime));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _db = GetIt.instance.get<DatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Full Post View"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _deviceHeight * 0.02),
          CustomExplorerListViewTile(
            deviceHeight: _deviceHeight,
            width: _deviceWidth * 0.80,
            post: widget.post,
            isOwnMessage: true,
            actions: true,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSortButton(SortBy.newest),
              const SizedBox(width: 10),
              _buildSortButton(SortBy.oldest),
              Expanded(
                child:
                    TextButton(onPressed: () {}, child: const Text('Comment')),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: _db.getUser(comment.senderID),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      Map<String, dynamic> userData =
                          snapshot.data?.data() as Map<String, dynamic>;
                      userData["uid"] = comment.senderID;
                      final commenter = AppUser.fromJSON(userData);
                      commenter;
                      return ListTile(
                        leading: RoundedImageNetwork(
                          key: UniqueKey(),
                          imagePath: commenter.imageURL,
                          size: _deviceWidth * 0.08,
                        ),
                        title: Text(comment.content),
                        subtitle: Text(
                            "${commenter.username}, ${timeago.format(comment.sentTime)} "),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    } else {
                      return const SizedBox.shrink(); // or a placeholder widget
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
              return Colors.blue; // Selected button color
            } else {
              return Colors.white; // Default button color
            }
          },
        ),
      ),
      child: Text(
        sortOption == SortBy.newest ? 'Newest' : 'Oldest',
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.black, // Text color based on selection
        ),
      ),
    );
  }
}
