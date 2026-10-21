import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(widget.article.url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka link artikel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final category = findCategory(article.category);
    final isBookmarked = context.watch<BookmarkProvider>().isBookmarked(article);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isWide = screenWidth >= 600;
    // Batasi tinggi gambar agar proporsional, dengan batas maks di layar lebar
    final imageHeight = isWide
        ? (screenWidth * 0.4).clamp(200.0, 400.0)
        : screenWidth * 0.65;
    final contentPad = isWide ? 32.0 : 20.0;
    final contentMaxWidth = 720.0;

    return Scaffold(
      // ─── AppBar transparan di atas gambar ───
      extendBodyBehindAppBar: article.imageUrl.isNotEmpty,
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        backgroundColor:
            article.imageUrl.isNotEmpty ? Colors.transparent : null,
        elevation: article.imageUrl.isNotEmpty ? 0 : null,
        foregroundColor: article.imageUrl.isNotEmpty ? Colors.white : null,
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () =>
                context.read<BookmarkProvider>().toggleBookmark(article),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Image dengan gradient overlay ───
            if (article.imageUrl.isNotEmpty)
              Stack(
                children: [
                  Image.network(
                    article.imageUrl,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: double.infinity,
                      height: imageHeight,
                      color: category.color.withValues(alpha: 0.15),
                      child: Center(
                        child: Icon(
                          category.icon,
                          size: isWide ? 80 : 64,
                          color: category.color.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay dari atas (untuk AppBar) dan bawah
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          stops: const [0.0, 0.25, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // ─── Konten artikel (di-center di layar lebar) ───
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.all(contentPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label kategori bergaya
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              category.color,
                              category.color.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Judul artikel
                      Text(
                        article.title,
                        style: TextStyle(
                          fontSize: isWide ? 26 : 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Info sumber & tanggal
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.newspaper_rounded,
                                size: 18, color: category.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                article.source,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            if (article.date.isNotEmpty) ...[
                              Container(
                                width: 1,
                                height: 16,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today_rounded,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                article.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Konten/deskripsi artikel
                      Text(
                        article.content.isNotEmpty
                            ? article.content
                            : article.description,
                        style: TextStyle(
                          fontSize: isWide ? 16 : 15,
                          height: 1.7,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ─── Tombol "Baca Selengkapnya" ───
                      if (article.url.isNotEmpty)
                        Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 400),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _openInBrowser,
                                icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 20),
                                label: const Text(
                                  'Baca Selengkapnya',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: category.color,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                  shadowColor:
                                      category.color.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
