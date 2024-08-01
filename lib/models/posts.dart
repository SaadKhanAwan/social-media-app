class Post {
  String? userId;
  String? postId;
  String? ownerId;
  String? name;
  int? timeStamp;
  String? imageUrl;
  String? caption;
  String? location;
  List<String>? likes;

  Post({
    this.postId,
    this.userId,
    this.ownerId,
    this.name,
    this.timeStamp,
    this.imageUrl,
    this.caption,
    this.location,
    this.likes,
  });

  factory Post.fromJson(Map<String, dynamic> json, id) {
    return Post(
      postId: id,
      userId: json['userId'] as String?,
      ownerId: json['ownerId'] as String?,
      name: json['name'] as String?,
      timeStamp: json['timeStamp'] as int?,
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      location: json['location'] as String?,
      likes: json['likes'] != null
          ? List<String>.from(json['likes'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['ownerId'] = ownerId;
    data['name'] = name;
    data['timeStamp'] = timeStamp;
    data['imageUrl'] = imageUrl;
    data['caption'] = caption;
    data['location'] = location;
    if (likes != null) {
      data['likes'] = likes!.map((v) => v).toList();
    }
    return data;
  }
}
