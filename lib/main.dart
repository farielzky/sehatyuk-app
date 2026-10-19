import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bookmark_provider.dart';
import 'screens/bookmark_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat data tersimpan (status login, bookmark) sebelum aplikasi tampil
  final authProvider = AuthProvider();
  final bookmarkProvider = BookmarkProvider();
  await authProvider.load();
  await bookmarkProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: bookmarkProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    return MaterialApp(
      title: 'SEHATYUK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      // Kalau sudah login, langsung ke Home
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
      },
    );
  }
}
