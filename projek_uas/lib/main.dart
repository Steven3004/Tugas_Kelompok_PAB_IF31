import 'package:flutter/material.dart';
import 'package:projek_uas/screen/add_post.dart';
import 'package:projek_uas/screen/sign_up_screen.dart';
import 'package:projek_uas/screen/sign_in_screen.dart';
import 'package:projek_uas/screen/splash_screen.dart';
import 'package:projek_uas/screen/home_screen.dart';
import 'package:projek_uas/screen/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); // ambil tema dari SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Wisata Anywhere',

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      routes: {
        '/login': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddPostScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
