import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/bookmark_provider.dart';
import 'screens/bookmark_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Muat data tersimpan (status login, bookmark) sebelum aplikasi tampil
  final authProvider = AuthProvider();
  final bookmarkProvider = BookmarkProvider();
  await authProvider.load();
  await bookmarkProvider.load();

  // Muat firebase untuk autentikasi dan database
  Firebase.initializeApp();

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
    return MaterialApp(
      title: 'SehatYuk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: appBackgroundColor,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      // Splash Screen selalu tampil pertama saat aplikasi dibuka
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
      },
    );
  }
}
