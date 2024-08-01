import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/helper/dateformate.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view/screens/comments.dart';
import 'package:social_media_app/view/screens/pages/profile.dart';
import 'package:social_media_app/view/screens/user_profile.dart';
import 'package:social_media_app/view/widgets/like_button.dart';

class PostCard extends StatefulWidget {
  final String id;
  final String name;
  final String userimage;
  final String image;
  final String timestamp;
  final String location;
  final String? postId;
  final List<String> like;
  final String caption;
  const PostCard(
      {super.key,
      required this.name,
      required this.timestamp,
      required this.postId,
      required this.like,
      required this.userimage,
      required this.location,
      required this.image,
      required this.caption,
      required this.id});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool islike = false;
  final auth = APi.user.email;
  @override
  void initState() {
    super.initState();
    islike = widget.like.contains(auth);
  }

  toggleit() {
    setState(() {
      islike = !islike;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade300,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mheight * .1),
              child: GestureDetector(
                onTap: () async {
                  handleProfileNavigation(context, widget.id);
                },
                child: CachedNetworkImage(
                  height: mheight * .19,
                  width: mwidth * .17,
                  fit: BoxFit.cover,
                  imageUrl: widget.userimage,
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
            ),
            title: Text(widget.name),
            subtitle: Text(widget.location),
            trailing: APi.user.uid == widget.id
                ? GestureDetector(
                    onTap: () {
                      buildAlertDialog(context: context,imageUrl: widget.image,postId: widget.postId.toString());
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ))
                : null,
          ),
        ),
        CachedNetworkImage(
          height: mheight * .37,
          width: double.infinity,
          fit: BoxFit.cover,
          imageUrl: widget.image,
          errorWidget: (context, url, error) =>
              const Icon(CupertinoIcons.person),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: mheight * .01,
            left: mwidth * .01,
          ),
          child: Row(
            children: [
              LikeDislike(
                islike: islike,
                onTab: () async {
                  toggleit();
                  await APi.likeIT(
                      postId: widget.postId.toString(),
                      islike: islike,
                      postImageUrl: widget.image);
                },
              ),
              SizedBox(
                width: mwidth * .05,
              ),
              InkWell(
                onTap: () {
                  log("PostID in card: ${widget.postId}");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CommentScreen(
                                postId: widget.postId.toString(),
                                image: widget.image,
                              )));
                },
                child: const Icon(
                  Icons.comment,
                  color: Colors.blue,
                  size: 39,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: mheight * .01,
            left: mwidth * .03,
          ),
          child: Row(
            children: [
              Text(
                widget.like.length.toString(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: mwidth * .05,
              ),
              const Text(
                "Likes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: mheight * .01,
            left: mwidth * .03,
            right: mwidth * .03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.caption.toString(),
                  maxLines: null,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: mwidth * .05,
              ),
              Flexible(
                child: Text(
                  MyDateUtlisP.getTime(
                    context: context,
                    time: widget.timestamp.toString(),
                  ),
                  maxLines: null,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }

  void handleProfileNavigation(BuildContext context, String userId) async {
    final currentUser = APi.user;

    // Check if the user ID matches the current user's ID
    if (userId == currentUser.uid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            me: APi.me,
          ),
        ),
      );
    } else {
      // Fetch the user profile data
      Users? user = await APi.getUserProfile(userId);
      log("Fetched user: $user");
      if (user != null) {
        // Navigate to the ProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(user: user),
          ),
        );
      }
    }
  }

  void buildAlertDialog(
      {required BuildContext context,
      required String postId,
      required String imageUrl}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Alert'),
          content: const Text('Are you sure you want to delete your post?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await APi.deletePost(postId, imageUrl).then(
                  (value) {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
