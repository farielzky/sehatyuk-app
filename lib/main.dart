import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/bookmark_provider.dart';
import 'screens/bookmark_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Load environment variables
  await dotenv.load(fileName: '.env');

  // 2. Initialize Firebase before using Firebase services
  await Firebase.initializeApp();

  // 3. Initialize application providers
  final bookmarkProvider = BookmarkProvider();
  await bookmarkProvider.load();

  // 4. Run application
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: bookmarkProvider)],
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
