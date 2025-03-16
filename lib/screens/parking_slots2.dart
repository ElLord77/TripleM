// lib/screens/parking_slots2.dart
import 'dart:math' as math;

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
                      RotatedSlotButton(slotName: 'LeftSlot1', ),
                      const SizedBox(height: 10,),
                      RotatedSlotButton(slotName: 'LeftSlot2', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot3', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot4', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot5', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot6', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot7', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'LeftSlot8', ),
                      const SizedBox(height: 100),

                    ],
                  ),
                ),
                const SizedBox(width: 170),

                // Right column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedSlotButton(slotName: 'RightSlot1', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot2', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot3', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot4', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot5', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot1', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot2', ),
                      const SizedBox(height: 10),
                      RotatedSlotButton(slotName: 'RightSlot3', ),
                      const SizedBox(height: 100),
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

class RotatedSlotButton extends StatelessWidget {
  final String slotName;

  const RotatedSlotButton({
    Key? key,
    required this.slotName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert degrees to radians

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

