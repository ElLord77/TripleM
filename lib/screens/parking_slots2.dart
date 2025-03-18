// lib/screens/parking_slots2.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/booking_screen.dart';

class ParkingSlots2 extends StatelessWidget {
  final String userPassword;
  final String imagePath = 'images/2.jpg';

  const ParkingSlots2({Key? key, required this.userPassword}) : super(key: key);

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
                      RotatedSlotButton(slotName: 'C1', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C2', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C3', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C4', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C5', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C6', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C7', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'C8', userPassword: userPassword),
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
                      RotatedSlotButton(slotName: 'D1', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D2', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D3', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D4', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D5', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D6', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D7', userPassword: userPassword),
                      const SizedBox(height: 1),
                      RotatedSlotButton(slotName: 'D8', userPassword: userPassword),
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
  final String userPassword;

  const RotatedSlotButton({
    Key? key,
    required this.slotName,
    required this.userPassword,
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
              builder: (context) => BookingScreen(
                slotName: slotName,
                userPassword: userPassword,
              ),
            ),
          );
        },
        child: Text(slotName),
      ),
    );
  }
}
