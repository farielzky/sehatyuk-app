import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../utils/constants.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Catat sebagai "terakhir dibaca" setelah halaman selesai dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkProvider>().setLastRead(widget.article);
    });
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final category = findCategory(article.category);
    final isBookmarked = context.watch<BookmarkProvider>().isBookmarked(article);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () =>
                context.read<BookmarkProvider>().toggleBookmark(article),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            const SizedBox(height: 12),

            // Label kategori
            Chip(
              avatar: Icon(category.icon, size: 18, color: category.color),
              label: Text(category.name),
              backgroundColor: category.color.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
            const SizedBox(height: 8),

            Text(
              article.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${article.source} • ${article.date}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              article.content.isNotEmpty ? article.content : article.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
