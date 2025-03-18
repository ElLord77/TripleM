// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: TripleMGarageApp(),
    ),
  );
}

class TripleMGarageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triple M Garage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
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
      home: HomeScreen(),
    );
  }
}
