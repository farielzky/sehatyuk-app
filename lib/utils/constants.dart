import 'package:flutter/material.dart';

/// Satu kategori artikel kesehatan.
/// Satu kategori artikel kesehatan.
class AppCategory {
  final String name; // nama lengkap (judul dan label di halaman detail)
  final String shortName; // nama singkat untuk chip di Home
  final String query; // kata kunci untuk pencarian ke API
  final IconData icon;
  final Color color; // warna utama (ikon, tombol)
  final Color lightColor; // warna latar lembut
  final Color darkColor; // warna teks kecil (kontras lebih baik)

  const AppCategory({
    required this.name,
    required this.shortName,
    required this.query,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.darkColor,
  });
}

// Warna aplikasi (token dari Figma)
const Color primaryColor = Color(0xFF0B8578);
const Color primaryDarkColor = Color(0xFF086B61);
const Color primaryLightColor = Color(0xFFE3F5F2);
const Color accentColor = Color(0xFFFF7A59);
const Color accentLightColor = Color(0xFFFFEDE8);
const Color appBackgroundColor = Color(0xFFF6FAF9);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color textPrimaryColor = Color(0xFF1F2933);
const Color textSecondaryColor = Color(0xFF5F6C76);
const Color textOnPrimaryColor = Color(0xFFFFFFFF);
const Color borderColor = Color(0xFFE4EBEA);
const Color errorColor = Color(0xFFD64545);
const Color successColor = Color(0xFF2E9E5B);

// Daftar kategori (warna & ikon beda-beda supaya tidak membosankan)
// Daftar kategori (nama, ikon, dan warna mengikuti Figma)
const List<AppCategory> categories = [
  AppCategory(
    name: 'Gizi & Nutrisi',
    shortName: 'Gizi',
    query: 'nutrition',
    icon: Icons.eco_outlined,
    color: Color(0xFF2F9E57),
    lightColor: Color(0xFFE4F5EA),
    darkColor: Color(0xFF1E7A40),
  ),
  AppCategory(
    name: 'Kesehatan Mental',
    shortName: 'Mental',
    query: 'mental health',
    icon: Icons.sentiment_satisfied_alt_outlined,
    color: Color(0xFF7C5CD6),
    lightColor: Color(0xFFEFEAFB),
    darkColor: Color(0xFF5B3FB5),
  ),
  AppCategory(
    name: 'Penyakit Umum',
    shortName: 'Penyakit',
    query: 'disease',
    icon: Icons.shield_outlined,
    color: Color(0xFFE4572E),
    lightColor: Color(0xFFFFEDE8),
    darkColor: Color(0xFFB93F22),
  ),
  AppCategory(
    name: 'Olahraga',
    shortName: 'Olahraga',
    query: 'fitness',
    icon: Icons.monitor_heart_outlined,
    color: Color(0xFF2F7DD1),
    lightColor: Color(0xFFE6F0FB),
    darkColor: Color(0xFF1F5FA8),
  ),
  AppCategory(
    name: 'Ibu & Anak',
    shortName: 'Ibu & Anak',
    query: 'mother and child',
    icon: Icons.favorite_border,
    color: Color(0xFFD6457F),
    lightColor: Color(0xFFFDE8F1),
    darkColor: Color(0xFFB02F65),
  ),
  AppCategory(
    name: 'Gaya Hidup',
    shortName: 'Gaya Hidup',
    query: 'healthy lifestyle',
    icon: Icons.local_cafe_outlined,
    color: Color(0xFFE8A317),
    lightColor: Color(0xFFFFF3D6),
    darkColor: Color(0xFF8F5C00),
  ),
];

// Kategori untuk chip "Semua" di Home (tidak masuk daftar categories)
const AppCategory allCategory = AppCategory(
  name: 'Kesehatan Umum',
  shortName: 'Kesehatan',
  query: 'health',
  icon: Icons.health_and_safety_outlined,
  color: primaryColor,
  lightColor: primaryLightColor,
  darkColor: primaryDarkColor,
);

/// Cari kategori berdasarkan nama. Kalau tidak ketemu, pakai kategori pertama.
AppCategory findCategory(String name) {
  if (name == allCategory.name) return allCategory;
  return categories.firstWhere(
    (c) => c.name == name,
    orElse: () => categories.first,
  );
}
