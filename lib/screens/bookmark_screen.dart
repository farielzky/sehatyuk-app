import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>().bookmarks;

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: bookmarks.isEmpty
          ? const Center(child: Text('Belum ada artikel yang di-bookmark'))
          : ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final article = bookmarks[index];
                return ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
