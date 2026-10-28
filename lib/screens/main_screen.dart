import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'bookmark_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Kerangka utama setelah login: halaman + bilah navigasi bawah.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0; // 0 Beranda, 1 Tersimpan, 2 Profil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga halaman tetap hidup, jadi posisi gulir
      // dan isi pencarian Home tidak hilang saat pindah tab
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          BookmarkScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) {
          // Tutup keyboard jika sedang terbuka (misalnya setelah mencari)
          FocusScope.of(context).unfocus();
          setState(() => _index = i);
        },
      ),
    );
  }
}