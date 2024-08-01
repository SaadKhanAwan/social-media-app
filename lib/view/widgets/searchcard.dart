import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';

import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view/screens/pages/profile.dart';
import 'package:social_media_app/view/screens/user_profile.dart';

class SearchCard extends StatefulWidget {
  final Users user;
  const SearchCard({super.key, required this.user});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (widget.user.id == APi.user.uid) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  me: widget.user,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  user: widget.user,
                ),
              ),
            );
          }
        },
        child: Card(
          color: Theme.of(context).primaryColor.withOpacity(1),
          elevation: 2,
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: widget.user.photoUrl.toString(),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.fill,
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.username.toString(),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.user.bio.toString(),
                        maxLines: null,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
