import 'package:bubbles_app/models/comment.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../widgets/custom_list_view_tiles.dart';

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
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: _deviceWidth * 0.05),
                child: DropdownButton<SortBy>(
                  value: _sortBy,
                  items: [
                    DropdownMenuItem(
                      value: SortBy.newest,
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: SortBy.oldest,
                      child: Text('Oldest'),
                    ),
                  ],
                  onChanged: (value) => _sortComments(value!),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  title: Text(comment.content),
                  subtitle: Text("${"comment.author"}, ${"comment.timestamp"}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
