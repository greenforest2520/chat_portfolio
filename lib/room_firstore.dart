import 'package:chat_portfolio/shared_prefs.dart';
import 'package:chat_portfolio/talk_room.dart';
import 'package:chat_portfolio/user.dart';
import 'package:chat_portfolio/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RoomFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance =
      FirebaseFirestore.instance;
  static final _roomCollection = _firebaseFirestoreInstance.collection("room");
  static final joinedRoomSnapshot = _roomCollection
      .where("joind_user_ids", arrayContains: SharedPrefs.fetchUid())
      .snapshots();
  final String talkUserUid = "";
  static Future<void> createRoom(String myuid) async {
    try {
      final docs = await UserFirestore.fetchUsers();
      if (docs == null) return;
      docs.forEach((doc) async {
        if (doc.id == myuid) return;
        await _roomCollection.add({
          "joind_user_ids": [doc.id, myuid],
          "created_time": Timestamp.now(),
          "user1": doc.id,
          "user2": myuid,
          "readUsers": <String>[],
        });
      });
    } catch (e) {
      //print("ルームの作成失敗==== $e");
    }
  }

  static Future<List<TalkRoom>?> fetchJoinedRooms(
      QuerySnapshot snapshot) async {
    try {
      String myuid = SharedPrefs.fetchUid()!;
      //print("フェッチしたuid");
      //print(myuid);

      final snapshot = await _roomCollection
          .where("joind_user_ids", arrayContains: myuid)
          .get();
      List<TalkRoom> talkRooms = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        List<dynamic> userids = data["joind_user_ids"];

        late String talkUserUid;
        for (var id in userids) {
          //print("ユーザー情報のデータ");
          //print(id);
          if (id == myuid) continue;
          talkUserUid = id;
        }
        //print("自分以外のトークユーザーユーザ一UID");
        //print(talkUserUid);

        UserInfo? talkUser = await UserFirestore.fetchProfile(talkUserUid);

        if (talkUser == null) return null;
        final talkRoom = TalkRoom(
          roomId: doc.id,
          talkUser: talkUser,
          lastMessage: doc.data()["last_message"],
          readUsers: doc.data()["readUsers"],
        );

        talkRooms.add(talkRoom);
        //print("------読み込み完了-----");
      }
      return talkRooms;
    } catch (e) {
      //print("参加ルームの取得失敗==$e");
      return null;
    }
  }

  static Stream<QuerySnapshot> fetchMessageSnapshot(String roomId) {
    return _roomCollection
        .doc(roomId)
        .collection("message")
        .orderBy("send_time", descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      {required String roomId,
      required String message,
      required String receiverUid}) async {
    try {
      final messageCollection =
          _roomCollection.doc(roomId).collection("message");
      final String sendMessage = message;
      final String senderId = SharedPrefs.fetchUid();
      // print("messageは");
      // print(message);
      // print("sendmessageは");
      // print(sendMessage.isNotEmpty);

      if (sendMessage.isNotEmpty) {
        await messageCollection.add({
          "message": message,
          "sender_id": senderId,
          "receiver_id": receiverUid,
          "send_time": Timestamp.now(),
          "readUsers": [],
        });

        await _roomCollection.doc(roomId).update({
          "last_message": message,
          "readUsers": [senderId, ""]
        });
      }
    } catch (e) {
      // print("メッセージの送信失敗 ====$e");
    }
  }
}
