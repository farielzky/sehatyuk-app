import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/secrets.dart';

/// Mengambil data artikel dari REST API.
/// Contoh ini memakai format NewsAPI (newsapi.org).
/// Kalau API yang dipilih beda, ubah baseUrl, parameter, dan Article.fromJson.
class ArticleService {
  static const String baseUrl = 'https://newsapi.org/v2/everything';

  static Future<List<Article>> fetchArticles({
    required String query,
    required String category,
  }) async {
    final uri = Uri.parse(
      '$baseUrl?q=${Uri.encodeComponent(query)}&language=en&pageSize=20&apiKey=$apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat artikel (kode ${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final List list = data['articles'] ?? [];

    return list.map((item) => Article.fromJson(item, category)).toList();
  }
}
