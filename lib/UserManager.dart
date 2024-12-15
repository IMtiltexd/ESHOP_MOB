import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }
}
