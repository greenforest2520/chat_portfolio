import 'package:chat_portfolio/room_firstore.dart';
import 'package:chat_portfolio/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../user.dart' as user_model;

class UserFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance =
      FirebaseFirestore.instance;
  static final _userCollection =
      _firebaseFirestoreInstance.collection("userInfo");
  //static final userCredential = FirebaseAuth.instance.currentUser?.uid;
  static final statusUsersnapshot = _userCollection.doc().get();
  static final documentId = _userCollection.doc().id;

  static Future<List<QueryDocumentSnapshot>?> fetchUsers() async {
    try {
      final snapshot = await _userCollection.get();
      snapshot.docs.forEach((doc) {
        //print("ドキュメントID:${doc.id} ---- 名前:${doc.data()["name"]}");
      });
      return snapshot.docs;
    } catch (e) {
      //print("ユーザー情報の取得失敗 ==== $e");
      return null;
    }
  }

  static Future<void> updateUser(user_model.UserInfo newProfile) async {
    try {
      await _userCollection
          .doc(newProfile.userId)
          .update({"name": newProfile.name, "imagePath": newProfile.imagePath});
    } catch (e) {
      //print("ユーザー情報の更新失敗　==== $e");
    }
  }

  static Future<user_model.UserInfo?> fetchProfile(String userId) async {
    try {
      print("自分以外のuid");
      print(userId);
      String uid = SharedPrefs.fetchUid()!;
      final snapshot = await _userCollection.doc(uid).get();
      user_model.UserInfo user = user_model.UserInfo(
        name: snapshot.data()!["name"],
        userId: userId,
      );
      return user;
    } catch (e) {
      //print("自分以外のユーザー情報の取得失敗-----$e");
    }
    return null;
  }
}
