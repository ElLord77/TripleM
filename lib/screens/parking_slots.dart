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
                      RotatedSlotButton(slotName: 'LeftSlot1', angleDegrees: 30),
                      const SizedBox(height: 55),
                      RotatedSlotButton(slotName: 'LeftSlot2', angleDegrees: 30),
                      const SizedBox(height: 60),
                      RotatedSlotButton(slotName: 'LeftSlot3', angleDegrees: 30),
                      const SizedBox(height: 40),
                      RotatedSlotButton(slotName: 'LeftSlot4', angleDegrees: 30),
                      const SizedBox(height: 30),
                      RotatedSlotButton(slotName: 'LeftSlot5', angleDegrees: 30),
                      const SizedBox(height: 50),
                      RotatedSlotButton(slotName: 'LeftSlot6', angleDegrees: 30),
                    ],
                  ),
                ),

                // Right column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedSlotButton(slotName: 'RightSlot1', angleDegrees: -30),
                      const SizedBox(height: 30),
                      RotatedSlotButton(slotName: 'RightSlot2', angleDegrees: -30),
                      const SizedBox(height: 30),
                      RotatedSlotButton(slotName: 'RightSlot3', angleDegrees: -30),
                      const SizedBox(height: 30),
                      RotatedSlotButton(slotName: 'RightSlot4', angleDegrees: -30),
                      const SizedBox(height: 30),
                      RotatedSlotButton(slotName: 'RightSlot5', angleDegrees: -30),
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
