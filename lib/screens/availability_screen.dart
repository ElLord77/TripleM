// lib/screens/availability_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/parking_slots.dart';
import 'package:gdp_app/screens/parking_slots2.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get the current theme

    return Scaffold(
      appBar: AppBar(
        // AppBar styling will come from main.dart's AppBarTheme
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg', // Your logo asset path
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text("Availability"), // Text color will come from AppBarTheme
          ],
        ),
      ),
      // scaffoldBackgroundColor will come from main.dart
      body: Center(
        child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Added GIF ---
              Image.asset(
                'images/level.gif', // IMPORTANT: Ensure this path is correct
                height: 300,
                width: 300,// Adjust height as needed
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if the GIF fails to load
                  return Container(
                    height: 150,
                    width: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('Level animation loading...'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30), // Space after GIF
              // --- End GIF ---

              Text(
                'Check Parking Level Availability', // Updated text
                style: theme.textTheme.headlineSmall?.copyWith(
                  // Color will be inherited from theme.textTheme.headlineSmall
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30), // Increased spacing
              ElevatedButton(
                // Style will come from theme.elevatedButtonTheme
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Make buttons a bit larger
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParkingSlots()),
                ),
                child: const Text('Level 1'), // Text color from ElevatedButtonTheme
              ),
              const SizedBox(height: 20), // Increased spacing
              ElevatedButton(
                // Style will come from theme.elevatedButtonTheme
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Make buttons a bit larger
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParkingSlots2()),
                ),
                child: const Text('Level 2'), // Text color from ElevatedButtonTheme
              ),
            ],
          ),
        ),
      ),
    );
  }
}
