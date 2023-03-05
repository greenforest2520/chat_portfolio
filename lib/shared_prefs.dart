import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future<void> setPrefsInstance() async {
    //インスタンス生成
    _preferences ??= await SharedPreferences.getInstance();
  }

  //端末に書き込む
  static Future<void> setUid(String uid) async {
    await _preferences!.setString("uid", uid);
  }

  //読み込む
  static fetchUid() {
    return _preferences!.getString("uid");
  }

  static revomeUid() {
    return _preferences?.remove("uid");
  }
}
