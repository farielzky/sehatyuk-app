import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';
import '../widgets/article_card.dart';
import '../widgets/circle_icon_button.dart';
import 'article_detail_screen.dart';

/// Daftar lengkap artikel (dipakai tombol "Lihat semua").
class ArticleListScreen extends StatelessWidget {
  final String title;
  final List<Article> articles;

  const ArticleListScreen({
    super.key,
    required this.title,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // --- Bilah atas: kembali dan judul ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 30 / 22,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${articles.length} artikel',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 18 / 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ),
                ),

                // --- Daftar artikel ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArticleDetailScreen(article: article),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}