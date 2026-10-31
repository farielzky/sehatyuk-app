import '../models/article.dart';
import '../utils/constants.dart';
import 'article_service.dart';

/// Mengambil artikel per kategori dengan cache sederhana (selama aplikasi terbuka)
/// supaya tidak boros kuota NewsAPI.
class ArticleFeed {
  // Selama ini cache dipakai begitu saja
  static const _cacheDuration = Duration(minutes: 15);

  // Tarik-untuk-memuat-ulang hanya mengambil data baru jika cache lebih tua dari ini
  static const _minRefreshInterval = Duration(minutes: 2);

  static final Map<String, List<Article>> _cache = {};
  static final Map<String, DateTime> _cachedAt = {};

  /// Artikel satu kategori.
  /// refresh: true = coba ambil data baru (tetap dibatasi 2 menit)
  /// shuffle: true = urutan artikel diacak
  static Future<List<Article>> forCategory(
    AppCategory category, {
    bool refresh = false,
    bool shuffle = false,
  }) async {
    final cachedAt = _cachedAt[category.name];
    final age = cachedAt == null ? null : DateTime.now().difference(cachedAt);

    final useCache = age != null &&
        (refresh ? age < _minRefreshInterval : age < _cacheDuration);

    List<Article> articles;
    if (useCache) {
      articles = _cache[category.name]!;
    } else {
      final fetched = await ArticleService.fetchArticles(
        query: category.query,
        category: category.name,
      );

      // NewsAPI kadang mengirim artikel yang sudah dihapus dengan judul "[Removed]"
      articles = fetched.where((a) => a.title != '[Removed]').toList();

      _cache[category.name] = articles;
      _cachedAt[category.name] = DateTime.now();
    }

    return shuffle ? ([...articles]..shuffle()) : articles;
  }

  /// Campuran artikel dari semua kategori.
  /// Urutan kategori dan artikel di tiap kategori diacak setiap dipanggil,
  /// lalu artikel diambil bergantian (satu dari tiap kategori).
  static Future<List<Article>> mixed({bool refresh = false}) async {
    final order = [...categories]..shuffle();

    Object? firstError;
    final results = await Future.wait(
      order.map((c) async {
        try {
          return await forCategory(c, refresh: refresh, shuffle: true);
        } catch (e) {
          // Satu kategori gagal tidak membatalkan yang lain
          firstError ??= e;
          return <Article>[];
        }
      }),
    );

    // Semua kategori gagal: lempar error agar Home menampilkan pesan dan "Coba lagi"
    final error = firstError;
    if (error != null && results.every((list) => list.isEmpty)) {
      throw error;
    }

    final longest = results.fold<int>(
      0,
      (max, list) => list.length > max ? list.length : max,
    );

    final mixedList = <Article>[];
    final seen = <String>{};
    for (var i = 0; i < longest; i++) {
      for (final list in results) {
        if (i >= list.length) continue;
        final article = list[i];
        final key = article.id.isEmpty ? article.title : article.id;
        if (seen.add(key)) mixedList.add(article);
      }
    }
    return mixedList;
  }
}