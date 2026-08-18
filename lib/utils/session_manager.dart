import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db_helper.dart';
import 'package:project_tride/Models/user_model.dart';

class SessionManager {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';

  /// Simpan session ketika user berhasil login.
  static Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setInt(keyUserId, userId);
  }

  /// Periksa apakah user sedang login.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  /// Dapatkan user ID yang sedang login.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserId);
  }

  /// Dapatkan data UserModel lengkap dari SQLite berdasarkan userId di session.
  static Future<UserModel?> getCurrentUser() async {
    final userId = await getUserId();
    if (userId == null) return null;
    return await DbHelper.instance.getUserById(userId);
  }

  /// Hapus session ketika user menekan tombol Logout.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUserId);
  }
}
