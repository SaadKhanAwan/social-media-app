import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view/screens/edit_profile.dart';
import 'package:social_media_app/view/screens/loginScreen.dart';
import 'package:social_media_app/Controller/services/authentication.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  Users me;
  ProfileScreen({super.key, required this.me});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authentication = Authentication();
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchFollowCounts();
  }

  void fetchFollowCounts() async {
    int followers = await APi.getFollowersCount(widget.me.id!);
    int following = await APi.getFollowingCount(widget.me.id!);
    setState(() {
      followersCount = followers - 1;
      followingCount = following - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: mheight * .01, left: mwidth * .05, right: mwidth * .05),
        child: ListView(children: [
          Column(
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
                      imageUrl: widget.me.photoUrl.toString(),
                      errorWidget: (context, url, error) =>
                          const Icon(CupertinoIcons.person),
                    ),
                  ),
                  Column(
                    children: [
                      FutureBuilder<List<Post>>(
                        future:
                            APi.fetchmyPosts(userId: widget.me.id.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int postCount = snapshot.data!.length;
                            return Column(
                              children: [
                                Text(
                                  postCount.toString(), // Display post count
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
                          // Add a loading indicator while fetching
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        followersCount.toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text("followers"),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        followingCount.toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("following"),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      final updatedMe = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditProfile(me: widget.me)),
                      );

                      if (updatedMe != null) {
                        setState(() {
                          widget.me =
                              updatedMe; // Update the me object in the state
                        });
                      }
                    },
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              Text(
                widget.me.username.toString(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.me.email.toString(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.me.bio.toString(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              FutureBuilder<List<Post>>(
                future: APi.fetchmyPosts(userId: widget.me.id.toString()),
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
                      itemCount: (posts.length / 3)
                          .ceil(), // Calculate total number of rows
                      itemBuilder: (context, index) {
                        int startIndex =
                            index * 2; // Starting index for this row
                        int endIndex = startIndex +
                            3; // Ending index for this row (max 2 after start)
                        endIndex = endIndex < posts.length
                            ? endIndex
                            : posts
                                .length; // Limit endIndex to actual post count

                        return Row(
                          children: [
                            for (int i = startIndex;
                                i < endIndex;
                                i++) // Loop for 3 images per row
                              Container(
                                constraints:
                                    BoxConstraints(maxWidth: mwidth * .32),
                                child: CachedNetworkImage(
                                  height: mheight * .25,
                                  width:
                                      mwidth * .30, // Match width to container
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
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          authentication.signOutWithGoogle().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          });
        },
        backgroundColor: Colors.red,
        label: const Text(
          "Logout",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        icon: const Icon(
          Icons.logout_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
