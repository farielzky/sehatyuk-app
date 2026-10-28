import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../services/article_service.dart';
import '../utils/constants.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_field.dart';
import '../widgets/section_header.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  AppCategory _selectedCategory = allCategory;
  String _keyword = ''; // kata pencarian yang sedang aktif
  late Future<List<Article>> _futureArticles;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ambil artikel: kalau kolom pencarian diisi, pakai kata itu; kalau kosong, pakai kategori
  void _loadArticles() {
    final keyword = _searchController.text.trim();
    _keyword = keyword;
    final query = keyword.isEmpty ? _selectedCategory.query : keyword;
    _futureArticles = ArticleService.fetchArticles(
      query: query,
      category: _selectedCategory.name,
    );
  }

  void _openDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  // Bagian atas yang menempel: header, pencarian, kategori, dan chip
  Widget _buildStickyTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Header ───
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: HomeHeader(),
        ),

        // ─── Kolom pencarian ───
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: HomeSearchField(
            controller: _searchController,
            onSubmitted: (_) => setState(_loadArticles),
          ),
        ),

        // ─── Kategori ───
        const SizedBox(height: 12),
        CategoryChips(
          selected: _selectedCategory,
          onSelected: (c) {
            setState(() {
              _selectedCategory = c;
              _searchController.clear();
              _loadArticles();
            });
          },
        ),
        const SizedBox(height:12),
      ],
    );
  }

  // Bagian bawah yang ikut bergeser: lanjutkan membaca dan artikel dari API
  Widget _buildScrollContent(Article? lastRead, double featuredHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Lanjutkan membaca ───
        if (lastRead != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: ContinueReadingCard(
              article: lastRead,
              onTap: () => _openDetail(lastRead),
            ),
          ),

        // ─── Artikel dari API (pilihan dan terbaru) ───
        _buildArticleSection(featuredHeight, lastRead == null ? 12 : 24),
      ],
    );
  }

  Widget _buildArticleSection(double featuredHeight, double topGap) {
    return FutureBuilder<List<Article>>(
      future: _futureArticles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(_loadArticles),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: Text('Artikel tidak ditemukan')),
          );
        }

        // 5 artikel pertama jadi "pilihan", sisanya "terbaru"
        final featured = articles.take(5).toList();
        final others = articles.skip(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, topGap, 24, 12),
              child: SectionHeader(
                title: _keyword.isEmpty ? 'Artikel pilihan' : 'Hasil pencarian',
                actionLabel: 'Lihat semua',
              ),
            ),
            SizedBox(
              height: featuredHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final article = featured[index];
                  return FeaturedArticleCard(
                    article: article,
                    onTap: () => _openDetail(article),
                  );
                },
              ),
            ),
            if (others.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 4),
                child: SectionHeader(title: 'Artikel terbaru'),
              ),
              for (final article in others)
                ArticleCard(
                  article: article,
                  onTap: () => _openDetail(article),
                ),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastRead = context.watch<BookmarkProvider>().lastRead;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tinggi kartu pilihan mengikuti ukuran font sistem agar tidak overflow
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final featuredHeight = 140 + 44 + 78 * textScale + 4;

    // Bagian atas hanya menempel di layar yang cukup tinggi
    final pinTop = screenHeight >= 600;

    final stickyTop = _buildStickyTop();
    final scrollContent = _buildScrollContent(lastRead, featuredHeight);

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Di layar lebar, isi dibatasi 720 px dan berada di tengah
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: pinTop
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      stickyTop,
                      Expanded(
                        child: SingleChildScrollView(child: scrollContent),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [stickyTop, scrollContent],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}