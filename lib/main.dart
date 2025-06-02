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

    return MaterialApp(
      title: 'Triple M Garage',
      debugShowCheckedModeBanner: false,

      // Light Theme (as previously defined)
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ).copyWith(
            secondary: Colors.amber[700],
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
            labelLarge: TextStyle(color: Colors.blue[800]),
            headlineSmall: TextStyle(color: Colors.black87),
            headlineMedium: TextStyle(color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: Colors.blue[700],
            textColor: Colors.grey[800],
            subtitleTextStyle: TextStyle(color: Colors.grey[600]),
          ),
          iconTheme: IconThemeData(
              color: Colors.blue[700]
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.grey[700]),
            hintStyle: TextStyle(color: Colors.grey[500]),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[700]!),
            ),
            border: const OutlineInputBorder(),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700]
              )
          ),
          cardTheme: CardTheme( // Define card theme for light mode
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white, // Explicitly white cards
          )
      ),

      // Refined Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A2647), // A deeper blue for primary elements
        scaffoldBackgroundColor: const Color(0xFF121212), // Standard very dark grey
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C2B3A), // Slightly lighter than scaffold, but still dark
          titleTextStyle: TextStyle(
            color: Color(0xFFE0E0E0), // Light grey text
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFE0E0E0)), // Light grey icons
        ),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue, // Base swatch, can be adjusted
        ).copyWith(
          primary: const Color(0xFF0A2647),
          secondary: const Color(0xFF205295), // A contrasting but harmonious blue for accents/buttons
          surface: const Color(0xFF1E1E1E), // Background for cards, dialogs (slightly lighter than scaffold)
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFFE0E0E0), // Text on scaffold
          onSurface: const Color(0xFFE0E0E0),    // Text on cards
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFD0D0D0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
          titleMedium: TextStyle(color: Color(0xFFF5F5F5)),
          titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
          labelLarge: TextStyle(color: Color(0xFFFFFFFF)), // For button text
          headlineSmall: TextStyle(color: Color(0xFFF5F5F5), fontWeight: FontWeight.bold), // Welcome text
          headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF205295), // Using the new secondary color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF205295), // Using the new secondary color for icons
          textColor: Color(0xFFE0E0E0),
          subtitleTextStyle: TextStyle(color: Color(0xFFA0A0A0)), // Lighter grey for subtitles
        ),
        iconTheme: const IconThemeData(
            color: Color(0xFFE0E0E0)
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08), // Slightly more opaque fill
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF205295)), // Use secondary color for focus
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF205295) // Use secondary color
            )
        ),
        cardTheme: CardTheme( // Define card theme for dark mode
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFF1E1E1E), // Explicit card color (colorScheme.surface)
        ),
      ),

      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
