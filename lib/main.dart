// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Import your providers
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/providers/theme_provider.dart';

// Import your initial screen
import 'package:gdp_app/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const TripleMGarageApp(),
    ),
  );
}

class TripleMGarageApp extends StatelessWidget {
  const TripleMGarageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // --- Light Theme Definition ---
    // Using ColorScheme.fromSeed to generate a full palette, then overriding
    // specific component themes to match your original design.
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple, // Your original purple base color
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.purple[700],
      ),
      iconTheme: IconThemeData(
          color: Colors.purple[700]
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple[700]!),
        ),
        border: const OutlineInputBorder(),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: Colors.purple[700]
          )
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // --- Dark Theme Definition ---
    // Using ColorScheme.fromSeed with your pink accent color, then overriding
    // specific component themes to match your original design.
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE94560), // Your original pink/red accent color
        brightness: Brightness.dark,
        // Override specific generated colors if needed
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE94560), // Keep your specific pink AppBar
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE94560), // Keep your accent color for buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFE94560),
      ),
      iconTheme: const IconThemeData(
          color: Color(0xFFE94560)
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE94560)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE94560)
          )
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: const Color(0xFF1E1E1E),
      ),
    );


    return MaterialApp(
      title: 'Triple M Garage',
      debugShowCheckedModeBanner: false,

      // Applying the new, more robust themes
      theme: lightTheme,
      darkTheme: darkTheme,

      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
