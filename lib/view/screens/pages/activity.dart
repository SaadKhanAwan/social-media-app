import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/helper/dateformate.dart';
import 'package:social_media_app/models/activity_field_item.dart';
import 'package:social_media_app/view/screens/user_profile.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    // final mwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: StreamBuilder<List<ActivityFeedItem>>(
        stream: APi.fetchActivityFeedItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<ActivityFeedItem>? feedItems = snapshot.data;

            if (feedItems!.length == 1 || feedItems.isEmpty) {
              return const Center(child: Text('No activity feed items found.'));
            }

            return ListView.builder(
              itemCount: feedItems.length,
              itemBuilder: (context, index) {
                ActivityFeedItem item = feedItems[index];
                return item.userId != APi.user.uid
                    ? GestureDetector(
                        onTap: () async {
                          var user = await APi.getUserById(item.userId);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      UserProfileScreen(user: user)));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: ClipOval(
                              child: CachedNetworkImage(
                                height: mheight * 0.07,
                                width: mheight * 0.07,
                                fit: BoxFit.cover,
                                imageUrl: item.userProfileImg,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(CupertinoIcons.person),
                              ),
                            ),
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: item.username
                                        .split(' ')
                                        .first
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const TextSpan(
                                      text:
                                          ' '), // Adding space between username and action
                                  TextSpan(
                                    text: _getActivityText(item),
                                    style: DefaultTextStyle.of(context).style,
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(MyDateUtlisP.getformattedTime(
                                context: context,
                                time: item.timestamp.toString())),
                            trailing: CachedNetworkImage(
                              height: mheight * 0.07,
                              width: mheight * 0.07,
                              fit: BoxFit.cover,
                              imageUrl: item.postImageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(CupertinoIcons.person),
                            ),
                          ),
                        ),
                      )
                    : null;
              },
            );
          }
        },
      ),
    );
  }

  String _getActivityText(ActivityFeedItem item) {
    switch (item.type) {
      case "like":
        return "Liked your photo";
      case "comment":
        return "Replied: ${item.comment.toString()}";
      case "follow":
        return "Started following you";
      default:
        return "";
    }
  }
}
