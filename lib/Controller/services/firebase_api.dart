import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/activity_field_item.dart';
import 'package:social_media_app/models/comments.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/user.dart';

class APi {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static CollectionReference activityfeed =
      FirebaseFirestore.instance.collection("feed");
  static late Users me;
  // static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // for  getting selfinformation for profile page
  static Future getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((isme) async {
      if (isme.exists) {
        me = Users.fromJson(isme.data()!);
      } else {
        await createUSer().then((value) => getSelfInfo());
      }
    });
  }

  static Future<Users> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return Users.fromDocument(userDoc);
  }

  static Future<Users?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return Users.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        log("User not found");
        return null;
      }
    } catch (e) {
      log("Error fetching user data in catch : $e");

      return null;
    }
  }

  // for chexking user exist
  static Future userExist() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  // for creating user
  static Future<void> createUSer() async {
    final times = DateTime.now();

    Users users = Users(
        id: user.uid,
        email: user.email,
        bio: "Feeling happy",
        username: user.displayName,
        photoUrl: user.photoURL,
        timestamp: times.toString());
    await firestore
        .collection("users")
        .doc(user.uid)
        .set(users.toJson())
        .then((val) async {
      await firestore.collection("users").doc(user.uid).update({
        'usernameLowercase': user.displayName!.toLowerCase(),
      });
    });

    // Follow the user (user follows themselves)
    await followUser(user.uid, user.uid);
  }

// for update user
  static Future<void> updateUSer() async {
    await firestore.collection("users").doc(user.uid).update({
      "bio": me.bio,
      "username": me.username,
    });
  }

  // for updating image
  static Future uploadProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child("profile-picture/${user.uid}.$ext");
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.photoUrl = await ref.getDownloadURL();
    firestore.collection("users").doc(user.uid).update({
      "photoUrl": me.photoUrl,
    });
  }

  

  // for searching user
  static Future<QuerySnapshot> searchUsers(String? searchValue) async {
    if (searchValue == null || searchValue.isEmpty) {
      return Future.error('Search value cannot be empty');
    }

    return firestore
        .collection('users')
        .where('usernameLowercase',
            isGreaterThanOrEqualTo: searchValue.toLowerCase())
        .where('usernameLowercase',
            isLessThanOrEqualTo: '${searchValue.toLowerCase()}\uf8ff')
        .get();
  }

  // for uploading image to storage
  static Future uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = storage.ref('images/${user.uid}$fileName/');
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image to Firebase Storage: $e');
    }
  }

  // for creating Post
  static Future<void> createPost(
    imageUrl,
    location,
    caption,
  ) async {
    final times = DateTime.now().millisecondsSinceEpoch;

    Post post = Post(
        userId: user.uid,
        ownerId: me.photoUrl,
        name: user.displayName,
        timeStamp: times,
        imageUrl: imageUrl,
        caption: caption,
        location: location,
        likes: []);
    await firestore.collection("post").add(post.toJson());
  }

  static Future<List<Post>> fetchmyPosts({required String userId}) async {
    List<Post> posts = [];
    // ignore: unused_local_variable
    int postCount = 0;

    try {
      final snapshot = await firestore
          .collection("post")
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          posts.add(Post.fromJson(doc.data(), doc.id));
          postCount++;
        }
      } else {
        debugPrint("No posts found.");
      }
    } catch (error) {
      debugPrint("Error fetching posts: $error");
    }

    return posts;
  }

  static Stream<List<Post>> fetchAllPosts() {
    return firestore
        .collection("post")
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data(), doc.id))
            .toList());
  }

  static Stream<List<Post>> fetchTimelinePosts(String userId) {
    return FirebaseFirestore.instance
        .collection('timeline')
        .doc(userId)
        .collection('timelinePosts')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data(), doc.id))
            .toList());
  }

  static Future<void> likeIT(
      {required bool islike,
      required String postId,
      required String postImageUrl}) async {
    final postRef = firestore.collection('post');

    try {
      final postSnapshot = await postRef.doc(postId).get();
      final postOwnerId = postSnapshot.data()?['userId'];
      if (islike) {
        await postRef.doc(postId).update({
          "likes": FieldValue.arrayUnion([user.email])
        });
        if (user.uid != postOwnerId) {
          await addLikeToActivityFeed(
            postId: postId,
            ownerId: postOwnerId,
            postImageUrl: postImageUrl,
          );
        }
      } else {
        await postRef.doc(postId).update({
          "likes": FieldValue.arrayRemove([user.email])
        });
        if (user.uid != postOwnerId) {
          await removeLikeFromActivityFeed(
              postId: postId, ownerId: postOwnerId);
        }
      }
      debugPrint("Successfully updated likes for post: $postId");
    } catch (error) {
      debugPrint("Error updating likes: $error");
    }
  }

  static Future uploadComment(
      {comment, postId, required String postImageUrl}) async {
    final postRef = firestore.collection('post');
    final times = DateTime.now().millisecondsSinceEpoch;

    try {
      final postSnapshot = await postRef.doc(postId).get();
      final onwerId = postSnapshot.data()?['userId'];

      CommentModel mycomment = CommentModel(
        userName: user.displayName.toString(),
        userPicture: user.photoURL.toString(),
        comment: comment,
        time: times.toString(),
      );
      postRef
          .doc(postId)
          .collection("Comments")
          .add(mycomment.toJson())
          .then((value) {
        if (user.uid != onwerId) {
          addCommentToActivityFeed(
              ownerId: onwerId, comment: comment, postImageUrl: postImageUrl);
        }
      });
    } catch (e) {
      log("error in catch :$e");
    }
  }

  static Stream<List<CommentModel>> fetchComment({
    postId,
  }) {
    final postRef = firestore.collection('post');
    try {
      return postRef
          .doc(postId)
          .collection("Comments")
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((docs) {
          return CommentModel.fromJson(docs.data());
        }).toList();
      });
    } catch (e) {
      log("error in catch: $e");
      return const Stream.empty();
    }
  }

  static Future<void> addLikeToActivityFeed({
    required String postId,
    required String ownerId,
    required String postImageUrl,
  }) async {
    try {
      final times = DateTime.now().millisecondsSinceEpoch;
      ActivityFeedItem activityFeedItem = ActivityFeedItem(
        type: "like",
        postImageUrl: postImageUrl,
        username: user.displayName.toString(),
        userId: user.uid,
        userProfileImg: user.photoURL.toString(),
        postId: postId,
        comment: "",
        timestamp: times.toString(),
      );
      final docId = '$postId-${user.uid}';
      await activityfeed
          .doc(ownerId)
          .collection("feedItems")
          .doc(docId)
          .set(activityFeedItem.toJson());
    } catch (error) {
      debugPrint("Error adding like to activity feed: $error");
    }
  }

  static Future<void> removeLikeFromActivityFeed({
    required String postId,
    required String ownerId,
  }) async {
    try {
      final docId = '$postId-${user.uid}';
      await activityfeed
          .doc(ownerId)
          .collection("feedItems")
          .doc(docId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    } catch (error) {
      debugPrint("Error removing like from activity feed: $error");
    }
  }

  static Future<void> addCommentToActivityFeed({
    required String ownerId,
    required String comment,
    required String postImageUrl,
  }) async {
    try {
      final times = DateTime.now().millisecondsSinceEpoch;
      ActivityFeedItem activityFeedItem = ActivityFeedItem(
        type: "comment",
        username: user.displayName.toString(),
        postImageUrl: postImageUrl,
        userId: user.uid,
        userProfileImg: user.photoURL.toString(),
        postId: ownerId,
        comment: comment,
        timestamp: times.toString(),
      );
      await activityfeed
          .doc(ownerId)
          .collection("feedItems")
          .add(activityFeedItem.toJson());
    } catch (error) {
      debugPrint("Error adding like to activity feed: $error");
    }
  }

  static Stream<List<ActivityFeedItem>> fetchActivityFeedItems() {
    final activityFeedRef = activityfeed
        .doc(user.uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true);

    return activityFeedRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityFeedItem.fromJson(doc.data());
      }).toList();
    });
  }

  static Future<void> deletePost(String postId, String imageUrl) async {
    try {
      // Delete the post document
      await firestore.collection("post").doc(postId).delete();

      // Delete the image from Firebase Storage
      Reference photoRef = storage.refFromURL(imageUrl);
      await photoRef.delete();

      // Delete activity feed notifications
      final activityFeedItems = await activityfeed
          .doc(user.uid)
          .collection("feedItems")
          .where("postId", isEqualTo: postId)
          .get();

      for (var doc in activityFeedItems.docs) {
        await doc.reference.delete();
      }

      // Delete all comments for the post
      final commentsSnapshot = await firestore
          .collection("post")
          .doc(postId)
          .collection("Comments")
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      log("Post and associated data successfully deleted");
    } catch (e) {
      log("Error deleting post and associated data: $e");
    }
  }

  ////////// **************************************************************////////////////

  static Future<void> followUser(
      String currentUserId, String targetUserId) async {
    try {
      // Add targetUserId to the current user's following collection
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .set({});

      // Add currentUserId to the target user's followers collection
      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .set({});

      // Add follow activity to activity feed
      await addFollowToActivityFeed(
          ownerId: targetUserId, userId: currentUserId);
    } catch (e) {
      log("Error following user: $e");
    }
  }

  static Future<void> addFollowToActivityFeed({
    required String ownerId,
    required String userId,
  }) async {
    try {
      final times = DateTime.now().millisecondsSinceEpoch;
      ActivityFeedItem activityFeedItem = ActivityFeedItem(
        type: "follow",
        postImageUrl: "",
        username: user.displayName.toString(),
        userId: user.uid,
        userProfileImg: user.photoURL.toString(),
        postId: "",
        comment: "",
        timestamp: times.toString(),
      );
      await activityfeed
          .doc(ownerId)
          .collection("feedItems")
          .doc(userId)
          .set(activityFeedItem.toJson());
    } catch (error) {
      debugPrint("Error adding follow to activity feed: $error");
    }
  }

  static Future<void> unfollowUser(
      String currentUserId, String targetUserId) async {
    try {
      // Remove targetUserId from the current user's following collection
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();

      // Remove currentUserId from the target user's followers collection
      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();

      // Remove follow activity from activity feed
      await removeFollowFromActivityFeed(
          ownerId: targetUserId, userId: currentUserId);
    } catch (e) {
      log("Error unfollowing user: $e");
    }
  }

  static Future<void> removeFollowFromActivityFeed({
    required String ownerId,
    required String userId,
  }) async {
    try {
      await activityfeed
          .doc(ownerId)
          .collection("feedItems")
          .doc(userId)
          .delete();
    } catch (error) {
      debugPrint("Error removing follow from activity feed: $error");
    }
  }

  static Future<bool> isFollowing(
      String currentUserId, String targetUserId) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      log("Error checking follow status: $e");
      return false;
    }
  }

  static Future<int> getFollowersCount(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();
      return snapshot.size;
    } catch (e) {
      log("Error fetching followers count: $e");
      return 0;
    }
  }

  static Future<int> getFollowingCount(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();
      return snapshot.size;
    } catch (e) {
      log("Error fetching following count: $e");
      return 0;
    }
  }
}
