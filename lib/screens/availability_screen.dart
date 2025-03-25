// lib/screens/availability_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/parking_slots.dart';
import 'package:gdp_app/screens/parking_slots2.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg', // Your logo asset path
              height: 30, // Adjust the height to make the logo smaller
            ),
            const SizedBox(width: 8),
            const Text("Availability"),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Check availability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkingSlots()),
              ),
              child: const Text('Level 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkingSlots2()),
              ),
              child: const Text('Level 2'),
            ),
          ],
        ),
      ),
    );
  }
}
