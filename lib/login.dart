import 'dart:math';

import 'package:chat_portfolio/room_firstore.dart';
import 'package:chat_portfolio/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final statusController = TextEditingController();

  String? email;
  String? password;

  String? imagePath;

  String? role;
  String? status;

  String? name;
  String? nigate;
  int? ticket;
  String? uid;

  //LoginModel(this.name, this.nigate, this.ticket, this.uid);

  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  Future<String?> fetchMyId() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;
    notifyListeners();
    return user?.uid;
  }

  Future login() async {
    email = mailController.text;
    password = passwordController.text;

    if (email != null && password != null) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser!.uid;
      //this.uid = uid;
      SharedPrefs.setPrefsInstance();
      SharedPrefs.setUid(uid);
      //print(uid);
    }
  }

  Future checkRole() async {
    final sharedUid = SharedPrefs.fetchUid().toString();
    // print("firebaseのuidは");
    // print(uid);
    // print(uid.runtimeType);
    // print("shredprefeceのuidは");
    // print(sharedUid);
    // print(sharedUid.runtimeType);
    // print("SharedUidは空じゃない");
    // print(sharedUid.isNotEmpty);

    if (sharedUid == "" || sharedUid.isEmpty || sharedUid == null.toString()) {
      return;
    } else if (sharedUid != "" ||
        sharedUid != null.toString() ||
        sharedUid.isNotEmpty) {
      final DocumentSnapshot sharedprefdocumentSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(sharedUid)
              .get();

      // print("このユーザーのfirebaseの値のroleは");
      // print(role);

      role = sharedprefdocumentSnapshot["role"];
    }
  }

  // anonymousUid() async {
  //   final userCredential = await FirebaseAuth.instance.signInAnonymously();
  //   uid = userCredential.user?.uid;
  //   notifyListeners();
  //   return uid;
  // }

  Future<void> anonymousSignup() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;
    final int random = Random().nextInt(10);

    if (user != null) {
      final uid = user.uid;

      print("アノニマス$uid");
      SharedPrefs.setUid(uid);

      final userdoc =
          FirebaseFirestore.instance.collection('userInfo').doc(uid);
      return userdoc
          .set({
            "name": "guest$random",
            "userId": uid,
          })
          .then((value) => print("情報追加成功"))
          .catchError((error) => print("追加失敗: $error"));
    }
  }
}
