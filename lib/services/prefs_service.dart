import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

/// Semua urusan baca/tulis SharedPreferences dikumpulkan di sini.
class PrefsService {
  static const _keyLogin = 'is_logged_in';
  static const _keyUsername = 'username';
  static const _keyBookmarks = 'bookmarks';
  static const _keyLastRead = 'last_read';

  // ---------- Login ----------
  static Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyUsername, username);
  }

  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, false);
    await prefs.remove(_keyUsername);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? '';
  }

  // ---------- Bookmark ----------
  static Future<void> saveBookmarks(List<Article> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyBookmarks, data);
  }

  static Future<List<Article>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyBookmarks) ?? [];
    return data.map((s) => Article.fromSaved(jsonDecode(s))).toList();
  }

  // ---------- Artikel terakhir dibaca ----------
  static Future<void> saveLastRead(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRead, jsonEncode(article.toJson()));
  }

  static Future<Article?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyLastRead);
    if (data == null) return null;
    return Article.fromSaved(jsonDecode(data));
  }
}
