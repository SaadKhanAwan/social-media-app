import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PostScreen extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? usernaem;
  final String? location;
  final String? describtion;
  final String? mediaUrl;
  int? likecounts;
  Map? likes;

  PostScreen(
      {super.key,
      this.postId,
      this.likecounts,
      this.ownerId,
      this.usernaem,
      this.location,
      this.describtion,
      this.mediaUrl});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
