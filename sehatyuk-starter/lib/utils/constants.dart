import 'package:flutter/material.dart';

/// Satu kategori artikel kesehatan.
class AppCategory {
  final String name; // nama yang tampil di aplikasi
  final String query; // kata kunci untuk pencarian ke API
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.query,
    required this.icon,
    required this.color,
  });
}

// Warna utama aplikasi
const Color primaryColor = Color(0xFF2E9E83);

// Daftar kategori (warna & ikon beda-beda supaya tidak membosankan)
const List<AppCategory> categories = [
  AppCategory(
    name: 'Gizi',
    query: 'nutrition',
    icon: Icons.restaurant,
    color: Color(0xFFF5A623),
  ),
  AppCategory(
    name: 'Penyakit',
    query: 'disease',
    icon: Icons.coronavirus,
    color: Color(0xFFE5533D),
  ),
  AppCategory(
    name: 'Mental',
    query: 'mental health',
    icon: Icons.psychology,
    color: Color(0xFF8E6BD8),
  ),
  AppCategory(
    name: 'Olahraga',
    query: 'fitness',
    icon: Icons.fitness_center,
    color: Color(0xFF3B8BEB),
  ),
  AppCategory(
    name: 'Gaya Hidup',
    query: 'healthy lifestyle',
    icon: Icons.spa,
    color: Color(0xFF2E9E83),
  ),
];

/// Cari kategori berdasarkan nama. Kalau tidak ketemu, pakai kategori pertama.
AppCategory findCategory(String name) {
  return categories.firstWhere(
    (c) => c.name == name,
    orElse: () => categories.first,
  );
}
