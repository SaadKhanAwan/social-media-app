import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/user.dart';

class UserProfileScreen extends StatefulWidget {
  final Users user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    fetchFollowCounts();
  }

  void checkIfFollowing() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      bool followingStatus =
          await APi.isFollowing(currentUserId, widget.user.id!);
      setState(() {
        isFollowing = followingStatus;
      });
    }
  }

  void fetchFollowCounts() async {
    int followers = await APi.getFollowersCount(widget.user.id!);
    int following = await APi.getFollowingCount(widget.user.id!);
    setState(() {
      followersCount = followers - 1;
      followingCount = following - 1;
    });
  }

  void handleFollowUnfollow() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      if (isFollowing) {
        await APi.unfollowUser(currentUserId, widget.user.id!);
        setState(() {
          isFollowing = false;
        });
      } else {
        await APi.followUser(currentUserId, widget.user.id!);
        setState(() {
          isFollowing = true;
        });
      }
      fetchFollowCounts(); // Refresh the counts after follow/unfollow
    }
  }

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username ?? 'User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    height: mheight * .13,
                    width: mwidth * .25,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.photoUrl.toString(),
                    errorWidget: (context, url, error) =>
                        const Icon(CupertinoIcons.person),
                  ),
                ),
                Column(
                  children: [
                    FutureBuilder<List<Post>>(
                      future:
                          APi.fetchmyPosts(userId: widget.user.id.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int postCount = snapshot.data!.length;
                          return Column(
                            children: [
                              Text(
                                postCount.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("Posts"),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      followersCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Followers"),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      followingCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Following"),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(),
                GestureDetector(
                  onTap: () {
                    handleFollowUnfollow();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      isFollowing ? "Unfollow" : "Follow",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.user.username.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.email.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.bio.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            FutureBuilder<List<Post>>(
              future: APi.fetchmyPosts(userId: widget.user.id.toString()),
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
                    itemCount: (posts.length / 3).ceil(),
                    itemBuilder: (context, index) {
                      int startIndex = index * 3;
                      int endIndex = startIndex + 3;
                      endIndex =
                          endIndex < posts.length ? endIndex : posts.length;

                      return Row(
                        children: [
                          for (int i = startIndex; i < endIndex; i++)
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: mwidth * .32),
                              child: CachedNetworkImage(
                                height: mheight * .25,
                                width: mwidth * .30,
                                fit: BoxFit.cover,
                                imageUrl: posts[i].imageUrl.toString(),
                                errorWidget: (context, url, error) =>
                                    const Icon(CupertinoIcons.person),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
