/// Model data satu artikel kesehatan.
class Article {
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String source;
  final String date;
  final String url;
  final String category;

  Article({
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.date,
    required this.url,
    required this.category,
  });

  // Dipakai untuk membandingkan artikel (misal: cek sudah di-bookmark atau belum)
  String get id => url;

  /// Ubah JSON dari API menjadi objek Article.
  /// Sesuaikan nama field ini kalau API yang dipakai berbeda.
  factory Article.fromJson(Map<String, dynamic> json, String category) {
    final String publishedAt = json['publishedAt'] ?? '';
    return Article(
      title: json['title'] ?? 'Tanpa judul',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      source: (json['source'] != null ? json['source']['name'] : null) ?? '-',
      date: publishedAt.length >= 10 ? publishedAt.substring(0, 10) : '',
      url: json['url'] ?? '',
      category: category,
    );
  }

  /// Dipakai untuk menyimpan ke SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'source': source,
      'date': date,
      'url': url,
      'category': category,
    };
  }

  /// Membaca kembali dari SharedPreferences.
  factory Article.fromSaved(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'] ?? '',
      date: json['date'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
