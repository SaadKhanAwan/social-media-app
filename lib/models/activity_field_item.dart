class ActivityFeedItem {
  final String type;
  final String username;
  final String userId;
  final String userProfileImg;
  final String postId;
  final String timestamp;
  final String postImageUrl;
  final String comment;

  ActivityFeedItem({
    required this.type,
    required this.postImageUrl,
    required this.comment,
    required this.username,
    required this.userId,
    required this.userProfileImg,
    required this.postId,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItem(
      postImageUrl: json['phthoUrl'] as String,
      type: json['type'] as String,
      comment: json['comment'] as String,
      username: json['username'] as String,
      userId: json['userId'] as String,
      userProfileImg: json['userProfileImg'] as String,
      postId: json['postId'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'phthoUrl':postImageUrl,
      'comment':comment,
      'username': username,
      'userId': userId,
      'userProfileImg': userProfileImg,
      'postId': postId,
      'timestamp': timestamp,
    };
  }
}
