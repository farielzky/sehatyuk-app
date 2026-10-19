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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEHATYUK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.pushNamed(context, '/bookmarks'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Halo, $username!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => setState(_loadArticles),
              decoration: InputDecoration(
                hintText: 'Cari artikel kesehatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Pilihan kategori
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
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

          // Artikel terakhir dibaca
          if (lastRead != null)
            Card(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              color: primaryColor.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.history, color: primaryColor),
                title: const Text('Terakhir dibaca', style: TextStyle(fontSize: 12)),
                subtitle: Text(
                  lastRead.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openDetail(lastRead),
              ),
            ),

          // Daftar artikel dari API
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
                          Text('${snapshot.error}', textAlign: TextAlign.center),
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
                  return const Center(child: Text('Artikel tidak ditemukan'));
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
    );
  }
}
