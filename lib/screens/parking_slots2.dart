// lib/screens/parking_slots2.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots2 extends StatelessWidget {
  final String imagePath = 'images/2.jpg'; // Your Level 2 image

  const ParkingSlots2({Key? key}) : super(key: key);

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
            const Text("Level 2 Parking"),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedSlotButton(slotName: 'C1'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C2'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C3'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C4'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C5'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C6'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C7'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C8'),
                      const SizedBox(height: 95),
                    ],
                  ),
                ),
                const SizedBox(width: 170),
                // Right column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedSlotButton(slotName: 'D1'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D2'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D3'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D4'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D5'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D6'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D7'),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D8'),
                      const SizedBox(height: 95),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RotatedSlotButton extends StatelessWidget {
  final String slotName;

  const RotatedSlotButton({
    Key? key,
    required this.slotName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
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
