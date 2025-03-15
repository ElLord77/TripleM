import 'package:flutter/material.dart';

// Import all other pages/screens:
import 'screens/home_screen.dart';

void main() {
  runApp(TripleMGarageApp());
}

class TripleMGarageApp extends StatelessWidget {
  @override
  //change 1
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Triple M Garage',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple, // Choose a suitable MaterialColor
          brightness: Brightness.dark,
        ).copyWith(
          secondary: const Color(0xFFE94560),
        ),
        primaryColor: const Color(0xFF1A1A2E),
        scaffoldBackgroundColor: const Color(0xFF16213E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F3460),
          titleTextStyle: TextStyle(
            color: Color(0xFFF9F9F9),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFF9F9F9)),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1A1A2E),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF9F9F9)),
          bodyLarge: TextStyle(color: Color(0xFFF9F9F9)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            foregroundColor: Color(0xFFF9F9F9),
          ),
        ),
      ),
      home: HomeScreen(), // Start at HomeScreen
    );
  }
}
