// lib/screens/parking_slots.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gdp_app/screens/slot_status_screen.dart'; // Ensure this path is correct

class ParkingSlots extends StatelessWidget {
  final String imagePath = 'images/1floor.jpg'; // Your Level 1 image

  const ParkingSlots({Key? key}) : super(key: key);

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
            const Text("Level 1 Parking"),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill, // This will stretch the image to fill the container
            ),
          ),
          // Main Row for A and B sections
          Positioned.fill(
            child: Row(
              // Removed mainAxisAlignment: MainAxisAlignment.spaceBetween
              // Children will now align to the start by default, after the initial SizedBox
              children: [
                // Added SizedBox to push all content to the right
                // Adjust this width to control how much the B columns are pushed
                const SizedBox(width: 80.0),

                // Left section (for B slots, now split into two columns)
                Expanded(
                  flex: 2, // Give B section a bit more space if needed, or keep flex:1 for equal
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute B columns
                    children: [
                      // First column of B slots (B1-B3)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Centers buttons vertically
                          children: [
                            RotatedSlotButton(slotName: 'B4', angleDegrees: 0),
                            const SizedBox(height: 50),
                            RotatedSlotButton(slotName: 'B5', angleDegrees: 0),
                            const SizedBox(height: 50),
                            RotatedSlotButton(slotName: 'B6', angleDegrees: 0),
                            const SizedBox(height: 150),

                          ],
                        ),
                      ),
                      // Second column of B slots (B4-B6)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Centers buttons vertically
                          children: [
                            RotatedSlotButton(slotName: 'B3', angleDegrees: 0),
                            const SizedBox(height: 50),
                            RotatedSlotButton(slotName: 'B2', angleDegrees: 0),
                            const SizedBox(height: 50),
                            RotatedSlotButton(slotName: 'B1', angleDegrees: 0),
                            const SizedBox(height: 150),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Adjust the width of this SizedBox to control the gap between the B section and A section
                const SizedBox(width: 50), // Reduced width a bit, adjust as needed
                // Right section (for A slots)
                Expanded(
                  flex: 1, // A section
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers buttons vertically
                    children: [
                      RotatedSlotButton(slotName: 'A1', angleDegrees: 90),
                      const SizedBox(height: 50),
                      RotatedSlotButton(slotName: 'A2', angleDegrees: 90),
                      const SizedBox(height: 50),
                      RotatedSlotButton(slotName: 'A3', angleDegrees: 90),
                      const SizedBox(height: 50),
                      RotatedSlotButton(slotName: 'A4', angleDegrees: 90),
                      const SizedBox(height: 50),
                      RotatedSlotButton(slotName: 'A5', angleDegrees: 90),
                      const SizedBox(height: 150),

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
      alignment: Alignment.center, // Ensures rotation happens around the center of the button
      child: Padding(
        padding: const EdgeInsets.all(3.0), // Adds a small padding around the button
        // Removed the SizedBox(width: double.infinity) that was wrapping the ElevatedButton
        child: ElevatedButton(
          onPressed: () {
            // Navigate to DashboardScreen when a slot button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SlotStatusScreen(slotName: slotName),
              ),
            );
          },
          child: Text(slotName),
        ),
      ),
    );
  }
}
