// lib/screens/availability_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/parking_slots.dart';
import 'package:gdp_app/screens/parking_slots2.dart';

class AvailabilityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triple M Garage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Check availability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParkingSlots()),
              ),
              child: Text('Level 1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParkingSlots2()),
              ),
              child: Text('Level 2'),
            ),
          ],
        ),
      ),
    );
  }
}
