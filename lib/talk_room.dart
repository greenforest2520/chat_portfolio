import 'user.dart';

class TalkRoom {
  String roomId;
  UserInfo talkUser;
  String? lastMessage;
  List<dynamic>? readUsers = [];

  TalkRoom({
    required this.roomId,
    required this.talkUser,
    this.lastMessage = "",
    this.readUsers,
  });
}
