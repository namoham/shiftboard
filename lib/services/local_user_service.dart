import 'package:shared_preferences/shared_preferences.dart';

class LocalUserService {
  static const _keyName = 'staff_name';
  static const _keyIsAdmin = 'is_admin';

  Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  Future<bool> getSavedIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAdmin) ?? false;
  }

  Future<void> saveUser(String name, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setBool(_keyIsAdmin, isAdmin);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyIsAdmin);
  }
}