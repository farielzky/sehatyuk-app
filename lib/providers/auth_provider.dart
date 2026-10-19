import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

/// State management untuk login / logout.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> load() async {
    _isLoggedIn = await PrefsService.isLoggedIn();
    _username = await PrefsService.getUsername();
    notifyListeners();
  }

  Future<void> login(String username) async {
    await PrefsService.saveLogin(username);
    _isLoggedIn = true;
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    await PrefsService.clearLogin();
    _isLoggedIn = false;
    _username = '';
    notifyListeners();
  }
}
