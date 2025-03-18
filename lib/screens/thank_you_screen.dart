// lib/screens/thank_you_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';

class ThankYouScreen extends StatelessWidget {
  final String slotName;
  final String date;
  final String startTime;
  final String leavingTime;
  final double amount;

  const ThankYouScreen({
    Key? key,
    required this.slotName,
    required this.date,
    required this.startTime,
    required this.leavingTime,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Thank You'),
        backgroundColor: const Color(0xFF0F3460),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thank you for your payment!',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFFF9F9F9),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Your parking slot ($slotName) has been booked on $date.\n'
                    'Arrival: $startTime\nLeaving: $leavingTime\nTotal Cost: £$amount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFF9F9F9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                ),
                child: const Text('Go Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
