import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';

/// Kartu artikel yang dipakai di Home dan Bookmark.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = findCategory(article.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: category.color.withValues(alpha: 0.15),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${article.category} • ${article.source}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
