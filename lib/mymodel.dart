import 'package:chat_portfolio/shared_prefs.dart';
import 'package:chat_portfolio/talk_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/widgets.dart';

class MyModel extends ChangeNotifier {
  String name = "";
  String status = "";
  String imagePath = "";
  String role = "";
  String token = "";
  bool result = false;

  final uid = SharedPrefs.fetchUid();
  final stringUid = SharedPrefs.fetchUid().toString();

  void trueResult() {
    result = true;
    notifyListeners();
  }

  Future createRoom(String selectUser) async {
    final check1 = await FirebaseFirestore.instance
        .collection("room")
        .where("user1", isEqualTo: selectUser)
        .where("user2", isEqualTo: uid)
        .get();
    print("$uidと$selectUserあるかないか${check1.docs}${check1.docs.isNotEmpty}");
    final check2 = await FirebaseFirestore.instance
        .collection("room")
        .where("user1", isEqualTo: uid)
        .where("user2", isEqualTo: selectUser)
        .get();
    print("$uidと$selectUserあるかないか${check2.docs}${check2.docs.isNotEmpty}");
    if (check1.docs.isEmpty && check2.docs.isEmpty) {
      await FirebaseFirestore.instance.collection("room").add({
        "joind_user_ids": [selectUser, uid],
        "created_time": Timestamp.now(),
        "user1": uid,
        "user2": selectUser,
        "readUsers": <String>[],
      });
      trueResult();
      print("書き込み$result");
      return result;
    } else {
      print("失敗$result");
      return result = false;
    }
  }
}
