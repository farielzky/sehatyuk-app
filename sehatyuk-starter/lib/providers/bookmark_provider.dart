import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/prefs_service.dart';

/// State management untuk bookmark dan artikel terakhir dibaca.
class BookmarkProvider extends ChangeNotifier {
  List<Article> _bookmarks = [];
  Article? _lastRead;

  List<Article> get bookmarks => _bookmarks;
  Article? get lastRead => _lastRead;

  Future<void> load() async {
    _bookmarks = await PrefsService.getBookmarks();
    _lastRead = await PrefsService.getLastRead();
    notifyListeners();
  }

  bool isBookmarked(Article article) {
    return _bookmarks.any((a) => a.id == article.id);
  }

  Future<void> toggleBookmark(Article article) async {
    if (isBookmarked(article)) {
      _bookmarks.removeWhere((a) => a.id == article.id);
    } else {
      _bookmarks.add(article);
    }
    await PrefsService.saveBookmarks(_bookmarks);
    notifyListeners();
  }

  Future<void> setLastRead(Article article) async {
    _lastRead = article;
    await PrefsService.saveLastRead(article);
    notifyListeners();
  }
}
