// lib/screens/parking_slots.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots extends StatelessWidget {
  final String userPassword; // pass to BookingScreen
  final String imagePath = 'images/1.jpg';

  const ParkingSlots({Key? key, required this.userPassword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level 1 Parking')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill,
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
                      RotatedSlotButton(slotName: 'A1', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A2', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A3', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A4', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A5', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A6', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A7', angleDegrees: 30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'A8', angleDegrees: 30, userPassword: userPassword),
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
                      RotatedSlotButton(slotName: 'B1', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B2', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B3', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B4', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B5', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B6', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B7', angleDegrees: -30, userPassword: userPassword),
                      const SizedBox(height: 20),
                      RotatedSlotButton(slotName: 'B8', angleDegrees: -30, userPassword: userPassword),
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

class RotatedSlotButton extends StatelessWidget {
  final String slotName;
  final double angleDegrees;
  final String userPassword;

  const RotatedSlotButton({
    Key? key,
    required this.slotName,
    required this.angleDegrees,
    required this.userPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => BookingScreen(
                  slotName: slotName,
                  userPassword: userPassword,
                ),
              ),
            );
          },
          child: Text(slotName),
        ),
      ),
    );
  }
}
