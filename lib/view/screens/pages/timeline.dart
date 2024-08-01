import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/view/widgets/post_card.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    // final mheight = MediaQuery.of(context).size.height;
    // final mwidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal,
          centerTitle: true,
          title: const Text(
            "FlutterShare",
            style: TextStyle(
                fontFamily: "Signatra", fontSize: 30, color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            StreamBuilder<List<Post>>(
                stream: APi.fetchTimelinePosts(APi.user.uid),
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
                    List<Post>? posts = snapshot.data;
                    if (posts == null || posts.isEmpty) {
                      return Column(
                        children: [
                          Image.asset("assets/images/no_content.png"),
                          const Text(
                            "No post found",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          )
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      itemCount: posts.length, // Calculate total number of rows
                      itemBuilder: (context, index) {
                        Post post = posts[index];
                        return PostCard(
                          id: post.userId ?? '',
                          name: post.name ?? '',
                          postId: post.postId ?? '',
                          caption: post.caption ?? '',
                          image: post.imageUrl ?? '',
                          location: post.location ?? '',
                          userimage: post.ownerId ?? '',
                          timestamp: post.timeStamp?.toString() ?? '',
                          like: post.likes ?? [],
                        );
                      },
                    );
                  }
                }),
          ],
        ));
  }
}
