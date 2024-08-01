const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onCreateFollower = functions.firestore
    .document('/users/{targetUserId}/followers/{currentUserId}')
    .onCreate(async (snapshot, context) => {
        const targetUserId = context.params.targetUserId;
        const currentUserId = context.params.currentUserId;
        console.log(`User ${currentUserId}   user ${targetUserId}`);

        try {
            // 1) create followed user posts ref
            const followedUserPostsRef = admin.firestore()
                .collection("post")
                .where('userId', '==', targetUserId);

            // 2) create following user timeline ref
            const timelinePostsRef = admin.firestore()
                .collection("timeline")
                .doc(currentUserId)
                .collection('timelinePosts');

            // 3) get followed user posts to following user's timeline
            const querySnapshot = await followedUserPostsRef.get();
            console.log(`Found ${querySnapshot.size} posts for user ${targetUserId}`);

            // 4) add each user post to following user's timeline
            const batch = admin.firestore().batch();
            querySnapshot.forEach(doc => {
                if (doc.exists) {
                    const postId = doc.id;
                    const postData = doc.data();
                    console.log(`Adding post ${postId} to timeline of user ${currentUserId}`);
                    batch.set(timelinePostsRef.doc(postId), postData);
                }
            });

            await batch.commit();
            console.log('Timeline posts created successfully');
        } catch (error) {
            console.error('Error creating timeline posts:', error);
        }
    });
    

    exports.onDeleteFollower = functions.firestore
    .document('/users/{targetUserId}/followers/{currentUserId}')
    .onDelete(async (snapshot, context) => {
        const targetUserId = context.params.targetUserId;
        const currentUserId = context.params.currentUserId;
        console.log(`User ${currentUserId} followed user ${targetUserId}`);

        try {
            // 1) create reference to the following user's timeline posts
            const timelinePostsRef = admin.firestore()
                .collection("timeline")
                .doc(currentUserId)
                .collection('timelinePosts')
                .where('userId', '==', targetUserId);

            // 2) get the timeline posts to delete
            const querySnapshot = await timelinePostsRef.get();

            console.log(`Found ${querySnapshot.size} posts to delete from timeline of user ${currentUserId}`);

            // 3) delete each post from the timeline
            const batch = admin.firestore().batch();
            querySnapshot.forEach(doc => {
                if (doc.exists) {
                    const postId = doc.id;
                    console.log(`Deleting post ${postId} from timeline of user ${currentUserId}`);
                    batch.delete(doc.ref);
                }
            });

            await batch.commit();
            console.log('Timeline posts deleted successfully');
        } catch (error) {
            console.error('Error deleting timeline posts:', error);
        }
    });

    // Triggered when a post is created
exports.onCreatePost = functions.firestore
.document('/post/{postId}')
.onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const postData = snapshot.data();
    const userId = postData.userId; // User who created the post

    console.log(`New post created by user ${userId}: ${postId}`);

    try {
        // Get all followers of the user
        const followersSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('followers')
            .get();

        const batch = admin.firestore().batch();

        followersSnapshot.forEach(followerDoc => {
            const followerId = followerDoc.id;
            console.log(`Adding post ${postId} to timeline of follower ${followerId}`);

            const timelinePostRef = admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId);
            batch.set(timelinePostRef, postData);
        });

        await batch.commit();
        console.log('Post added to followers timelines successfully');
    } catch (error) {
        console.error('Error adding post to followers timelines:', error);
    }
});


// Triggered when a post is updated
exports.onUpdatePost = functions.firestore
    .document('/post/{postId}')
    .onUpdate(async (change, context) => {
        const postId = context.params.postId;
        const newPostData = change.after.data(); // Updated post data
        const userId = newPostData.userId; // User who created the post

        console.log(`Post updated by user ${userId}: ${postId}`);

        try {
            // Get all followers of the user
            const followersSnapshot = await admin.firestore()
                .collection('users')
                .doc(userId)
                .collection('followers')
                .get();

            const batch = admin.firestore().batch();

            followersSnapshot.forEach(followerDoc => {
                const followerId = followerDoc.id;
                console.log(`Updating post ${postId} in timeline of follower ${followerId}`);

                const timelinePostRef = admin.firestore()
                    .collection('timeline')
                    .doc(followerId)
                    .collection('timelinePosts')
                    .doc(postId);
                batch.set(timelinePostRef, newPostData); // Update the post data
            });

            await batch.commit();
            console.log('Followers timelines updated successfully');
        } catch (error) {
            console.error('Error updating followers timelines:', error);
        }
    });

    // Triggered when a post is deleted
exports.onDeletePost = functions.firestore
.document('/post/{postId}')
.onDelete(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = snapshot.data().userId; // User who created the post

    console.log(`Post deleted by user ${userId}: ${postId}`);

    try {
        // Get all followers of the user
        const followersSnapshot = await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('followers')
            .get();

        const batch = admin.firestore().batch();

        followersSnapshot.forEach(followerDoc => {
            const followerId = followerDoc.id;
            console.log(`Deleting post ${postId} from timeline of follower ${followerId}`);

            const timelinePostRef = admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId);
            batch.delete(timelinePostRef); // Remove the post from the follower's timeline
        });

        await batch.commit();
        console.log('Post deleted from followers timelines successfully');
    } catch (error) {
        console.error('Error deleting post from followers timelines:', error);
    }
});



exports.notifyUserOnFeedActivity = functions.firestore
    .document('/feed/{ownerId}/feedItems/{docId}')
    .onCreate(async (snapshot, context) => {
        const ownerId = context.params.ownerId;
        const activityData = snapshot.data();
        const activityType = activityData.type; // "comment", "like", or "follow"
        const userId = activityData.userId; // The user who performed the activity

        try {
            // Get the owner user document
            const userDoc = await admin.firestore().collection('users').doc(ownerId).get();
            const userData = userDoc.data();
            const fcmToken = userData.fcmToken;

            if (fcmToken) {
                // Create the notification body based on the activity type
                let notificationBody;
                switch (activityType) {
                    case 'comment':
                        notificationBody = `${activityData.username} commented on your post: ${activityData.comment}`;
                        break;
                    case 'like':
                        notificationBody = `${activityData.username} liked your post!`;
                        break;
                    case 'follow':
                        notificationBody = `${activityData.username} started following you!`;
                        break;
                    default:
                        console.log('Unknown activity type:', activityType);
                        return;
                }

                // Create the message for push notification
                const payload = {
                    notification: {
                        title: `New ${activityType.charAt(0).toUpperCase() + activityType.slice(1)}`,
                        body: notificationBody,
                        sound: 'default',
                    },
                };

                // Send the message with admin.messaging
                await admin.messaging().sendToDevice(fcmToken, payload);
                console.log(`Notification sent to user ${ownerId} for ${activityType}`);
            } else {
                console.log(`User ${ownerId} does not have a FCM token`);
            }
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    });