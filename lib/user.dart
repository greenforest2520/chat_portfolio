import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String name;

  final String userId;
  final String? imagePath;

  const UserInfo({
    required this.name,
    required this.userId,
    this.imagePath,
  });
}
