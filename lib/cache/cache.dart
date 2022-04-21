import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {


  static const _keyUsername = 'username';
  static const _keyNames = 'names';

  static Future setUsername(String username) async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    await _preferences.setString(_keyUsername, username);
  }


  static Future getUsername() async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    return _preferences.getString(_keyUsername);
  }

  static Future setInt(String key, int value) async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    await _preferences.setInt(key, value);
  }

  static Future getInt(String key) async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    return _preferences.getInt(key);
  }

  static Future setStringList(String key, List<String> list) async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    await _preferences.setStringList(key, list);
  }

  static Future getStringList(String key) async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    return _preferences.getStringList(key);
  }

  static Future clearAll() async {
    final SharedPreferences _preferences = await SharedPreferences
        .getInstance();
    await _preferences.clear();
    return true;
  }
}