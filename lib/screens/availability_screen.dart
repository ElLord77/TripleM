// lib/screens/availability_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // import the utility
import 'package:gdp_app/screens/parking_slots.dart';
import 'package:gdp_app/screens/parking_slots2.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPassword = Provider.of<UserProvider>(context).userPassword;

    return Scaffold(
      appBar: AppBar(
        title: Text('Triple M Garage'),
        actions: [
          // Add the same 3-dot menu
          buildOverflowMenu(context),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Check availability',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF9F9F9),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingSlots(userPassword: userPassword),
                ),
              ),
              child: Text('Level 1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingSlots2(userPassword: userPassword),
                ),
              ),
              child: Text('Level 2'),
            ),
          ],
        ),
      ),
    );
  }
}
