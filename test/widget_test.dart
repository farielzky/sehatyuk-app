import 'package:flutter_test/flutter_test.dart';
import 'package:sehatyuk/models/article.dart';

void main() {
  test('Article.fromJson membaca data dengan benar', () {
    final json = {
      'title': 'Tips Sehat',
      'description': 'Deskripsi',
      'url': 'https://contoh.com/a',
      'publishedAt': '2026-10-19T10:00:00Z',
      'source': {'name': 'Contoh News'},
    };

    final article = Article.fromJson(json, 'Gizi');

    expect(article.title, 'Tips Sehat');
    expect(article.source, 'Contoh News');
    expect(article.date, '2026-10-19');
    expect(article.category, 'Gizi');
  });
}
