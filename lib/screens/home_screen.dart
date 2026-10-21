import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/auth_provider.dart';
import '../providers/bookmark_provider.dart';
import '../services/article_service.dart';
import '../utils/constants.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  AppCategory _selectedCategory = categories.first;
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

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final lastRead = context.watch<BookmarkProvider>().lastRead;
    final username = context.watch<AuthProvider>().username;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isWide = screenWidth >= 600; // tablet / landscape
    final hPad = isWide ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEHATYUK'),
        centerTitle: isWide,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.pushNamed(context, '/bookmarks'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header: Salam ───
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Halo, $username!',
                  style: TextStyle(
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ─── Kolom pencarian ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => setState(_loadArticles),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel kesehatan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Pilihan kategori ───
            SizedBox(
              height: isWide ? 52 : 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad - 4),
                children: categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      avatar: Icon(c.icon, size: 18, color: c.color),
                      label: Text(c.name),
                      selected: c == _selectedCategory,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = c;
                          _searchController.clear();
                          _loadArticles();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // ─── Artikel terakhir dibaca ───
            if (lastRead != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    color: primaryColor.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: primaryColor),
                      title: const Text('Terakhir dibaca',
                          style: TextStyle(fontSize: 12)),
                      subtitle: Text(
                        lastRead.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openDetail(lastRead),
                    ),
                  ),
                ),
              ),

            // ─── Daftar artikel dari API ───
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: _futureArticles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${snapshot.error}',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(_loadArticles),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final articles = snapshot.data ?? [];
                  if (articles.isEmpty) {
                    return const Center(
                        child: Text('Artikel tidak ditemukan'));
                  }

                  // ─── Responsive: grid 2 kolom di layar lebar ───
                  if (isWide) {
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: hPad - 16, vertical: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return ArticleCard(
                          article: article,
                          onTap: () => _openDetail(article),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () => _openDetail(article),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
