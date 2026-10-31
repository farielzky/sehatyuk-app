import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../utils/constants.dart';
import '../widgets/circle_icon_button.dart';

/// Halaman artikel: memuat artikel penuh dari situs penerbit di dalam aplikasi.
/// Jika gagal dimuat, tampil ringkasan artikel (desain Figma) sebagai cadangan.
class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  WebViewController? _controller;
  Uri? _uri;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Catat sebagai "terakhir dibaca" setelah halaman selesai dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkProvider>().setLastRead(widget.article);
    });

    _setupWebView();
  }

  void _setupWebView() {
    // Alamat http diubah ke https karena Android memblokir http biasa
    final raw = widget.article.url.replaceFirst('http://', 'https://');
    final uri = Uri.tryParse(raw);

    // Link tidak valid: langsung tampilkan ringkasan
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      _hasError = true;
      return;
    }
    _uri = uri;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value / 100);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _hasError = false);
          },
          onWebResourceError: (error) {
            // Hanya kegagalan halaman utama yang dianggap error
            if (error.isForMainFrame ?? true) {
              if (mounted) setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(uri);
  }

  void _retry() {
    final controller = _controller;
    final uri = _uri;
    if (controller == null || uri == null) return;

    setState(() {
      _hasError = false;
      _progress = 0;
    });
    controller.loadRequest(uri);
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.article.url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
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

    final controller = _controller;
    final showWeb = !_hasError && controller != null;
    final host = (_uri?.host ?? '').replaceFirst('www.', '');
    final isSecure = _uri?.scheme == 'https';

    // Tombol kembali HP: mundur di riwayat situs dulu, baru menutup halaman
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (showWeb && await controller.canGoBack()) {
          await controller.goBack();
        } else if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // --- Bilah atas: kembali, alamat, buka di browser, bookmark ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSecure ? Icons.lock_outline : Icons.public,
                              size: 14,
                              color: textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                host.isEmpty ? article.source : host,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleIconButton(
                      icon: Icons.open_in_new,
                      onTap: article.url.isEmpty ? null : _openExternal,
                    ),
                    const SizedBox(width: 8),
                    CircleIconButton(
                      icon: isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: isBookmarked ? primaryColor : textPrimaryColor,
                      onTap: () => context
                          .read<BookmarkProvider>()
                          .toggleBookmark(article),
                    ),
                  ],
                ),
              ),

              // --- Baris kecil: kategori dan sumber ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: category.lightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(category.icon, size: 14, color: category.color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category == allCategory ? article.source : '${category.name}  •  ${article.source}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: category.darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Garis kemajuan memuat halaman ---
              SizedBox(
                height: 3,
                child: (showWeb && _progress < 1)
                    ? LinearProgressIndicator(
                        value: _progress,
                        minHeight: 3,
                        color: primaryColor,
                        backgroundColor: borderColor,
                      )
                    : const ColoredBox(color: borderColor),
              ),

              // --- Artikel penuh, atau ringkasan jika gagal dimuat ---
              Expanded(
                child: showWeb
                    ? WebViewWidget(controller: controller)
                    : _buildFallback(article, category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tampilan cadangan: ringkasan artikel (desain Figma) dan tombol coba lagi
  Widget _buildFallback(Article article, AppCategory category) {
    final rawContent =
        article.content.isNotEmpty ? article.content : article.description;
    final isTruncated = RegExp(r'\[\+\d+ chars\]').hasMatch(rawContent);
    final body = _cleanContent(rawContent);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Pemberitahuan ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: accentLightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_off, size: 18, color: accentColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Artikel lengkap tidak bisa dimuat. '
                              'Ini ringkasannya.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 18 / 12,
                                color: textPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Gambar utama ---
                    _Hero(article: article, category: category),
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

                    // --- Ringkasan isi ---
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
                        'Buka di browser untuk membaca versi penuh.',
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

        // --- Bilah tombol: coba lagi dan buka di browser ---
        Container(
          decoration: const BoxDecoration(
            color: surfaceColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  if (_uri != null)
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _retry,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ),
                  if (_uri != null && article.url.isNotEmpty)
                    const SizedBox(width: 12),
                  if (article.url.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _openExternal,
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
                          child: const Text('Buka di browser'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
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