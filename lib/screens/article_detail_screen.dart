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

  // NewsAPI menambahkan potongan seperti "[+1234 chars]" di akhir isi
  String _cleanContent(String text) {
    return text.replaceAll(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final category = findCategory(article.category);
    final isBookmarked =
        context.watch<BookmarkProvider>().isBookmarked(article);

    final rawContent =
        article.content.isNotEmpty ? article.content : article.description;
    final isTruncated = RegExp(r'\[\+\d+ chars\]').hasMatch(rawContent);
    final body = _cleanContent(rawContent);

    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Center(
                  // Di layar lebar, isi dibatasi 720 px dan berada di tengah
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Baris atas: kembali dan bookmark ---
                        Row(
                          children: [
                            _CircleIconButton(
                              icon: Icons.arrow_back,
                              color: textPrimaryColor,
                              onTap: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            _CircleIconButton(
                              icon: isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? primaryColor
                                  : textPrimaryColor,
                              onTap: () => context
                                  .read<BookmarkProvider>()
                                  .toggleBookmark(article),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Gambar utama ---
                        _Hero(article: article, category: category),
                        const SizedBox(height: 16),

                        // --- Label kategori ---
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: category.lightColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                category.icon,
                                size: 14,
                                color: category.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                category.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.88,
                                  height: 16 / 11,
                                  color: category.darkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Judul ---
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 30 / 22,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Sumber dan tanggal ---
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: primaryLightColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                article.source,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ),
                            if (article.date.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.schedule,
                                size: 14,
                                color: textSecondaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                article.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Garis denyut pemisah ---
                        SizedBox(
                          height: 16,
                          width: double.infinity,
                          child: CustomPaint(painter: _PulseDividerPainter()),
                        ),
                        const SizedBox(height: 16),

                        // --- Isi artikel ---
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 22 / 14,
                            color: textPrimaryColor,
                          ),
                        ),
                        if (isTruncated) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Isi artikel dipotong oleh sumbernya. '
                            'Tekan "Baca selengkapnya" untuk membaca versi penuh.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 18 / 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Bilah tombol di bawah ---
            Container(
              decoration: const BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              article.url.isEmpty ? null : _openInBrowser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: textOnPrimaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Baca selengkapnya'),
                              SizedBox(width: 8),
                              Icon(Icons.open_in_new, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
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

/// Tombol bulat 40 px (putih, border tipis) untuk baris atas.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      shape: const CircleBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

/// Gambar utama 180 px: gambar artikel jika ada, kalau tidak ilustrasi kategori.
class _Hero extends StatelessWidget {
  final Article article;
  final AppCategory category;

  const _Hero({required this.article, required this.category});

  @override
  Widget build(BuildContext context) {
    final illustration = Stack(
      children: [
        // Dua lingkaran dekorasi (sebagian keluar dari kotak)
        Positioned(
          top: -70,
          right: -78,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -30,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.09),
            ),
          ),
        ),
        Center(
          child: Icon(category.icon, size: 72, color: category.color),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        width: double.infinity,
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

/// Garis tipis dengan satu lonjakan denyut jantung, mengikuti Figma.
class _PulseDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Lonjakan berada sekitar 43% dari sisi kiri
    final dx = size.width * (146 / 342);
    final path = Path()
      ..moveTo(0, 8)
      ..lineTo(dx, 8)
      ..lineTo(dx + 6, 8)
      ..lineTo(dx + 12, 2)
      ..lineTo(dx + 20, 14)
      ..lineTo(dx + 26, 5)
      ..lineTo(dx + 30, 8)
      ..lineTo(size.width, 8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}