import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../utils/constants.dart';

/// Kartu artikel (baris) yang dipakai di Home dan Bookmark.
/// Mengikuti komponen ArticleRow di Figma.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = findCategory(article.category);
    final isBookmarked =
        context.watch<BookmarkProvider>().isBookmarked(article);

    // Waktu baca tidak tersedia dari API, jadi tampilkan sumber dan tanggal
    final meta = article.date.isEmpty
        ? article.source
        : '${article.source} • ${article.date}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Thumbnail(article: article, category: category),
                const SizedBox(width: 12),

                // --- Label kategori, judul, dan info sumber ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != allCategory) ...[
                        Text(
                          category.shortName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.88,
                            height: 16 / 11,
                            color: category.darkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 22 / 15,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 18 / 12,
                                color: textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // --- Tombol bookmark ---
                InkWell(
                  onTap: () =>
                      context.read<BookmarkProvider>().toggleBookmark(article),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: isBookmarked ? primaryColor : textSecondaryColor,
                    ),
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

/// Thumbnail 84 px: gambar artikel jika ada, kalau tidak ilustrasi kategori.
class _Thumbnail extends StatelessWidget {
  final Article article;
  final AppCategory category;

  const _Thumbnail({required this.article, required this.category});

  @override
  Widget build(BuildContext context) {
    // Ilustrasi: lingkaran dekorasi di pojok kanan atas dan ikon kategori
    final illustration = Stack(
      children: [
        Positioned(
          top: -14,
          left: 48,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.14),
            ),
          ),
        ),
        Center(
          child: Icon(category.icon, size: 32, color: category.color),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        height: 84,
        child: ColoredBox(
          color: category.lightColor,
          child: article.imageUrl.isEmpty
              ? illustration
              : Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => illustration,
                ),
        ),
      ),
    );
  }
}