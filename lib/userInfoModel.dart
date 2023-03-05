import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfoModel extends ChangeNotifier {
  String name = "";
  String nigate = "";
  int ticket = 0;
  String userId = "";
  final currentUser = FirebaseAuth.instance.currentUser;

  late String? uid = currentUser?.uid;

  Future<void> fetchUser() async {
    if (currentUser != null) {
      print(currentUser!.uid);
      final snapshot = await FirebaseFirestore.instance
          .collection("UserInfo")
          .doc(uid)
          .get();
      final data = snapshot.data();

      name = data!["name"];
      nigate = data["nigate"];
      ticket = data["ticket"];
      userId = data["userId"];
      print(name + nigate + ticket.toString() + userId);
      name = name;
      nigate = nigate;
      ticket = ticket;
      userId = userId;
    } else if (uid == null) {
      return null;
    }
    notifyListeners();
  }
}
