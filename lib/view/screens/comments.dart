import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/helper/dateformate.dart';
import 'package:social_media_app/models/comments.dart';
import 'package:social_media_app/view/widgets/textfield.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String image;

  const CommentScreen({super.key, required this.postId, required this.image});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Comments",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: APi.fetchComment(postId: widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<CommentModel>? comments = snapshot.data;
                  if (comments == null || comments.isEmpty) {
                    return ListView(
                      children: [
                        Image.asset("assets/images/no_content.png"),
                        const Center(
                          child: Text(
                            "No comments found",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        )
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      CommentModel comment = comments[index];
                      return buildComment(comment);
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "Enter comment",
                    controller: commentController,
                  ),
                ),
                MaterialButton(
                  colorBrightness: Brightness.light,
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      APi.uploadComment(
                        postImageUrl:widget.image ,
                        postId: widget.postId,
                        comment: commentController.text.trim(),
                      );
                      commentController.clear();
                    }
                  },
                  child: const Text("Comment"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildComment(CommentModel model) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  height: mheight * 0.05,
                  width: mheight * 0.05,
                  fit: BoxFit.cover,
                  imageUrl: model.userPicture,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
              SizedBox(
                width: mwidth * 0.02,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(model.comment),
                  ],
                ),
              ),
              Text(MyDateUtlisP.getformattedTime(
                  context: context, time: model.time.toString()))
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
