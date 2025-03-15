// lib/screens/parking_slots2.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots2 extends StatelessWidget {
  final String imagePath = 'images/2.jpg'; // Your Level 2 image path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level 2 Parking')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          _buildSlotButton(context, 'Slot 1A', 150, 20),
          _buildSlotButton(context, 'Slot 2A', 210, 20),
          _buildSlotButton(context, 'Slot 3A', 275, 20),
          _buildSlotButton(context, 'Slot 4A', 335, 20),
          _buildSlotButton(context, 'Slot 5A', 400, 20),
          _buildSlotButton(context, 'Slot 6A', 460, 20),
          _buildSlotButton(context, 'Slot 7A', 525, 20),
          _buildSlotButton(context, 'Slot 8A', 585, 20),
          _buildSlotButton(context, 'Slot 1B', 150, 330),
          _buildSlotButton(context, 'Slot 2B', 210, 330),
          _buildSlotButton(context, 'Slot 3B', 275, 330),
          _buildSlotButton(context, 'Slot 4B', 335, 330),
          _buildSlotButton(context, 'Slot 5B', 400, 330),
          _buildSlotButton(context, 'Slot 6B', 460, 330),
          _buildSlotButton(context, 'Slot 7B', 525, 330),
          _buildSlotButton(context, 'Slot 8B', 585, 330),
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
