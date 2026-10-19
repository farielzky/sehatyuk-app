# SEHATYUK

Aplikasi mobile informasi kesehatan berbasis Flutter. Dibuat sebagai proyek kelompok (3 orang).

## Fitur
- Login / logout (status login disimpan di SharedPreferences)
- Daftar artikel kesehatan per kategori
- Pencarian artikel
- Halaman detail artikel
- Bookmark artikel (SharedPreferences)
- Riwayat artikel terakhir dibaca
- Data dari REST API (JSON)

Alur: Login → Home → Kategori → Artikel → Detail → Bookmark

## Teknologi
Flutter, Dart (OOP), Provider (state management), http, shared_preferences

## Cara Menjalankan
1. Pastikan Flutter terpasang (cek dengan `flutter --version`)
2. Clone repo: `git clone https://github.com/farielzky/sehatyuk-app`
3. Masuk folder project, lalu jalankan:
   ```
   flutter pub get
   flutter run
   ```
4. Buat file `lib/utils/secrets.dart` (tidak ikut di-commit):
   ```dart
   const String apiKey = 'ISI_API_KEY_KAMU';
   ```

## Struktur Folder
```
lib/
├── main.dart            # titik awal aplikasi + routing
├── models/              # class data (Article)
├── services/            # akses API & SharedPreferences
├── providers/           # state management (auth, bookmark)
├── screens/             # halaman (login, home, detail, bookmark)
├── widgets/             # widget kecil yang dipakai ulang
└── utils/               # konstanta (kategori, warna)
```

## Aturan Kerja Tim (satu branch `main`)
1. Sebelum mulai kerja: `git pull`
2. Kerjakan file bagianmu saja (lihat pembagian tugas)
3. Selesai: `git add .` → `git commit -m "pesan jelas"` → `git pull` → `git push`
4. Kalau muncul conflict, jangan panik: buka file yang conflict, pilih kode yang benar, lalu commit lagi
5. Jangan commit API key

## Pembagian Tugas
| Anggota | Bagian |
|---------|--------|
| Ariel   | (isi)  |
| Anggota 2 | (isi) |
| Anggota 3 | (isi) |

## Anggota Tim
- Ariel
- (isi)
- (isi)
