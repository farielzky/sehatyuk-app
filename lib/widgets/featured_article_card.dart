import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';

/// Kartu besar horizontal untuk "Artikel pilihan" di Home (lebar 260 px).
class FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = findCategory(article.category);

    // Waktu baca tidak tersedia dari API, jadi tampilkan sumber dan tanggal
    final meta = article.date.isEmpty
        ? article.source
        : '${article.source} • ${article.date}';

    return SizedBox(
      width: 260,
      child: Material(
        color: surfaceColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Gambar atau ilustrasi kategori (tinggi 140) ---
              SizedBox(
                height: 140,
                width: double.infinity,
                child: _Cover(article: article, category: category),
              ),

              // --- Label, judul, dan info sumber ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 22 / 16,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 18 / 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bagian atas kartu: gambar artikel jika ada, kalau tidak ilustrasi kategori.
class _Cover extends StatelessWidget {
  final Article article;
  final AppCategory category;

  const _Cover({required this.article, required this.category});

  @override
  Widget build(BuildContext context) {
    final illustration = Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.09),
            ),
          ),
        ),
        Center(
          child: Icon(category.icon, size: 44, color: category.color),
        ),
      ],
    );

    return ColoredBox(
      color: category.lightColor,
      child: article.imageUrl.isEmpty
          ? illustration
          : Image.network(
              article.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => illustration,
            ),
    );
  }
}