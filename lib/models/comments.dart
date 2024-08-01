
class CommentModel {
  final String userPicture;
  final String userName;
  final String time;
  final String comment;

  CommentModel({
    required this.userPicture,
    required this.userName,
    required this.time,
    required this.comment,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userPicture: json['userPicture'] as String,
      userName: json['userName'] as String,
      time: json['time'] ,
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPicture': userPicture,
      'userName': userName,
      'time': time,
      'comment': comment,
    };
  }
}
