import 'package:chat_portfolio/room_firstore.dart';
import 'package:chat_portfolio/shared_prefs.dart';
import 'package:chat_portfolio/talk_room.dart';
import 'package:chat_portfolio/talk_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mymodel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String uid = SharedPrefs.fetchUid();
  bool isRead(List readUsers) {
    //User? user = FirebaseAuth.instance.currentUser;

    if (readUsers.contains(uid)) {
      return false;
    }

    return true;
  }

  readAction(String roomId, List readUsers) {
    if (!readUsers.contains(uid)) {
      readUsers.add(uid);
    }
    FirebaseFirestore.instance
        .collection('room')
        .doc(roomId)
        .update({'readUsers': readUsers});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("チャット"),
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: RoomFirestore.joinedRoomSnapshot,
              builder: (context, streamsnapshot) {
                if (streamsnapshot.hasData) {
                  return FutureBuilder<List<TalkRoom>?>(
                      future:
                          RoomFirestore.fetchJoinedRooms(streamsnapshot.data!),
                      builder: (context, futureSnapshot) {
                        if (futureSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          if (futureSnapshot.hasData) {
                            List<TalkRoom> talkRooms = futureSnapshot.data!;
                            return ListView.builder(
                                itemCount: talkRooms.length,
                                itemBuilder: (context, index) {
                                  return ChangeNotifierProvider<MyModel>(
                                      create: (_) => MyModel(),
                                      child: Consumer<MyModel>(
                                          builder: ((context, model, child) {
                                        return InkWell(
                                          onTap: () async {
                                            if (talkRooms[index].readUsers !=
                                                null) {
                                              await readAction(
                                                  talkRooms[index].roomId,
                                                  talkRooms[index].readUsers!);
                                            }
                                            // print(
                                            //   talkRooms[index].talkUser.name,
                                            // );
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TalkRoomPage(
                                                            talkRooms[index])));
                                          },
                                          // onLongPress: () {
                                          //   showDialog(
                                          //       context: context,
                                          //       builder: (context) {
                                          //         return AlertDialog(
                                          //           title: const Text("削除します"),
                                          //           content: const Text(
                                          //               "トーク履歴も\n削除されます。\nよろしいですか？"),
                                          //           actions: [
                                          //             TextButton(
                                          //                 onPressed: () {
                                          //                   Navigator.pop(
                                          //                       context);
                                          //                 },
                                          //                 child: const Text(
                                          //                     "CANCEL")),
                                          //             TextButton(
                                          //                 onPressed: () async {
                                          //                   await model
                                          //                       .deleteRoom(
                                          //                           talkRooms[
                                          //                               index]);
                                          //                   if (!mounted)
                                          //                     return;
                                          //                   Navigator.pop(
                                          //                       context);
                                          //                   // print("ログアウトタップ");
                                          //                   // print(model.role);

                                          //                   // print(SharedPrefs.fetchUid());
                                          //                 },
                                          //                 child:
                                          //                     const Text("OK"))
                                          //           ],
                                          //         );
                                          //       });
                                          // },
                                          child: SizedBox(
                                            height: 70,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage: talkRooms[
                                                                      index]
                                                                  .talkUser
                                                                  .imagePath ==
                                                              ""
                                                          ? null
                                                          : NetworkImage(
                                                              talkRooms[index]
                                                                  .talkUser
                                                                  .imagePath
                                                                  .toString())),
                                                ),
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        talkRooms[index]
                                                            .talkUser
                                                            .name,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        talkRooms[index]
                                                                .lastMessage ??
                                                            "",
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ]),
                                                const Expanded(
                                                    child: SizedBox()),
                                                Visibility(
                                                  visible: talkRooms[index]
                                                              .readUsers !=
                                                          null
                                                      ? isRead(talkRooms[index]
                                                          .readUsers!)
                                                      : false,
                                                  //false,
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(25),
                                                    child: CircleAvatar(
                                                      maxRadius: 4,
                                                      backgroundColor:
                                                          Colors.deepOrange,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      })));
                                });
                          } else {
                            return const Center(child: Text("トークルームの取得失敗"));
                          }
                        }
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
    );
  }
}
