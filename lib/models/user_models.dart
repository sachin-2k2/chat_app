import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String usid;
  final String name;
  final String email;
  final String profileImage;
  bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.usid,
    required this.name,
    required this.email,
    required this.profileImage,
    this.isOnline = false,
    this.lastSeen,
  });

  //convert firstore data to user Usermodel

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      usid: map['usid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert UserModel to Firestore data

  Map<String, dynamic> toMap() {
    return {
      'usid': usid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}
