import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? username;
  String? photoUrl;
  String? email;
  String? bio;
  String? timestamp;

  Users(
      {this.id,
      this.username,
      this.photoUrl,
      this.email,
      this.bio,
      this.timestamp});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    photoUrl = json['photoUrl'];
    email = json['email'];
    bio = json['bio'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['photoUrl'] = photoUrl;
    data['email'] = email;
    data['bio'] = bio;
    data['timestamp'] = timestamp;
    return data;
  }

  factory Users.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      username: data['username'],
      photoUrl: data['photoUrl'],
      email: data['email'],
      bio: data['bio'],
      timestamp: data['timestamp'],
    );
  }
}
