// lib/screens/parking_slots.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots extends StatelessWidget {
  final String imagePath = 'images/1.jpg'; // Your image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level 1 Parking')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          _buildSlotButton(context, 'Slot 1A', 80, 30),
          _buildSlotButton(context, 'Slot 2A', 160, 30),
          _buildSlotButton(context, 'Slot 3A', 240, 30),
          _buildSlotButton(context, 'Slot 4A', 320, 30),
          _buildSlotButton(context, 'Slot 5A', 405, 30),
          _buildSlotButton(context, 'Slot 6A', 485, 30),
          _buildSlotButton(context, 'Slot 7A', 568, 30),
          _buildSlotButton(context, 'Slot 8A', 650, 30),
          _buildSlotButton(context, 'Slot 1B', 80, 330),
          _buildSlotButton(context, 'Slot 2B', 160, 330),
          _buildSlotButton(context, 'Slot 3B', 240, 330),
          _buildSlotButton(context, 'Slot 4B', 320, 330),
          _buildSlotButton(context, 'Slot 5B', 405, 330),
          _buildSlotButton(context, 'Slot 6B', 485, 330),
          _buildSlotButton(context, 'Slot 7B', 568, 330),
          _buildSlotButton(context, 'Slot 8B', 650, 330),
        ],
      ),
    );
  }

  Positioned _buildSlotButton(BuildContext context, String slotName, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(slotName: slotName),
            ),
          );
        },
        child: Text(slotName),
      ),
    );
  }
}
