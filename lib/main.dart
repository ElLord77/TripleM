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

    // Define icon colors to be used for AppBar background - Reverted
    final Color lightModeAppBarColor = Colors.purple.shade600; // Purple for light mode AppBar
    final Color darkModeAppBarColor = Colors.pink.shade300;   // Pink for dark mode AppBar

    // Define foreground color for AppBar elements (title, icons)
    const Color appBarForegroundColor = Colors.white;


    return MaterialApp(
      title: 'Triple M Garage',
      debugShowCheckedModeBanner: false,

      // Light Theme (Purple-based)
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.purple, // Back to purple
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: lightModeAppBarColor, // Purple background
            foregroundColor: appBarForegroundColor,
            titleTextStyle: const TextStyle(
              color: appBarForegroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: appBarForegroundColor),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
            brightness: Brightness.light,
          ).copyWith(
            secondary: Colors.orangeAccent,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onBackground: Colors.black,
            onSurface: Colors.black,
            surface: Colors.white,
            background: Colors.grey[50],
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.grey[900]),
            bodyMedium: TextStyle(color: Colors.grey[800]),
            titleLarge: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black87),
            titleSmall: TextStyle(color: Colors.black54),
            labelLarge: TextStyle(color: Colors.purple[800]),
            headlineSmall: TextStyle(color: Colors.black87),
            headlineMedium: TextStyle(color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
            ),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: Colors.purple[700],
            textColor: Colors.grey[800],
            subtitleTextStyle: TextStyle(color: Colors.grey[600]),
          ),
          iconTheme: IconThemeData(
              color: Colors.purple[700]
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.grey[700]),
            hintStyle: TextStyle(color: Colors.grey[500]),
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
            color: Colors.white,
          )
      ),

      // Dark Theme (Pink-based, using your original accent for buttons)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: darkModeAppBarColor, // Using pink
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: darkModeAppBarColor, // Pink background
          titleTextStyle: const TextStyle(
            color: appBarForegroundColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: appBarForegroundColor),
        ),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.pink, // Aligning with AppBar
        ).copyWith(
          primary: darkModeAppBarColor,
          secondary: const Color(0xFFE94560), // Your original dark theme accent
          surface: const Color(0xFF1E1E1E),
          onPrimary: Colors.white,
          onSecondary: Colors.white, // Text on pink accent buttons
          onBackground: const Color(0xFFE0E0E0),
          onSurface: const Color(0xFFE0E0E0),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFD0D0D0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
          titleMedium: TextStyle(color: Color(0xFFF5F5F5)),
          titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
          labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
          headlineSmall: TextStyle(color: Color(0xFFF5F5F5), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560), // Your original dark theme accent for buttons
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: const Color(0xFFE94560), // Your original dark theme accent
          textColor: const Color(0xFFE0E0E0),
          subtitleTextStyle: const TextStyle(color: Color(0xFFA0A0A0)),
        ),
        iconTheme: IconThemeData(
            color: const Color(0xFFE94560) // General icons to match your original dark theme accent
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE94560)), // Accent for focus
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE94560) // Accent for text buttons
            )
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFF1E1E1E),
        ),
      ),

      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
