import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../services/prefs_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Article> _bookmarks = [];
  Article? _lastRead;

  String? _currentUid;
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Article>>? _bookmarkSubscription;

  List<Article> get bookmarks => _bookmarks;
  Article? get lastRead => _lastRead;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookmarkProvider() {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthStateChanged,
    );
  }

  /// Memuat data lokal yang masih digunakan, yaitu lastRead.
  Future<void> load() async {
    _lastRead = await PrefsService.getLastRead();
    notifyListeners();
  }

  /// Menangani perubahan pengguna yang sedang login.
  void _handleAuthStateChanged(User? user) {
    final newUid = user?.uid;

    if (newUid == _currentUid) return;

    _currentUid = newUid;

    _bookmarkSubscription?.cancel();
    _bookmarks = [];
    _errorMessage = null;

    if (newUid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _bookmarkSubscription = _bookmarkService
        .watchBookmarks(newUid)
        .listen(
          (bookmarks) {
            if (_currentUid != newUid) return;

            _bookmarks = bookmarks;
            _isLoading = false;
            _errorMessage = null;

            notifyListeners();
          },
          onError: (Object error) {
            if (_currentUid != newUid) return;

            _isLoading = false;
            _errorMessage = 'Gagal memuat bookmark: $error';

            notifyListeners();
          },
        );
  }

  /// Memeriksa apakah artikel sudah di-bookmark.
  bool isBookmarked(Article article) {
    return _bookmarks.any((item) => item.id == article.id);
  }

  /// Menambahkan atau menghapus bookmark.
  Future<void> toggleBookmark(Article article) async {
    final uid = _currentUid;

    if (uid == null) {
      throw StateError('Pengguna belum login.');
    }

    try {
      if (isBookmarked(article)) {
        await _bookmarkService.removeBookmark(uid, article);
      } else {
        await _bookmarkService.addBookmark(uid, article);
      }

      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Gagal memperbarui bookmark: $error';
      notifyListeners();
      rethrow;
    }
  }

  /// Menyimpan artikel terakhir dibaca secara lokal.
  Future<void> setLastRead(Article article) async {
    _lastRead = article;
    await PrefsService.saveLastRead(article);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _bookmarkSubscription?.cancel();
    super.dispose();
  }
}
