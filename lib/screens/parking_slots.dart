import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots extends StatelessWidget {
  final String imagePath = 'images/1.jpg'; // Your image path

  const ParkingSlots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level 1 Parking')),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill,
            ),
          ),

          // Two columns in a Row
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Example: 6 angled buttons on the left
                      RotatedSlotButton(slotName: 'A1', angleDegrees: 30),
                      const SizedBox(height: 20,),
                      RotatedSlotButton(slotName: 'A2', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A3', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A4', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A5', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A6', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A7', angleDegrees: 30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A8', angleDegrees: 30),
                      const SizedBox(height: 90),

                    ],
                  ),
                ),
                const SizedBox(width: 100),

                // Right column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedSlotButton(slotName: 'B1', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B2', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B3', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B4', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B5', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B6', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B7', angleDegrees: -30),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B8', angleDegrees: -30),
                      const SizedBox(height: 90),
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

/// A reusable widget that rotates the button by [angleDegrees].
class RotatedSlotButton extends StatelessWidget {
  final String slotName;
  final double angleDegrees;

  const RotatedSlotButton({
    Key? key,
    required this.slotName,
    required this.angleDegrees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert degrees to radians
    final double angleInRadians = angleDegrees * math.pi / 180;

    return Transform.rotate(
      angle: angleInRadians,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
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
      ),
    );
  }
}
