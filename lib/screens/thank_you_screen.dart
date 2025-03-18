// lib/screens/thank_you_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ThankYouScreen extends StatelessWidget {
  final String slotName;
  final String date;
  final String time;

  const ThankYouScreen({
    Key? key,
    required this.slotName,
    required this.date,
    required this.time,
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
                'Your parking slot ($slotName) has been booked on $date at $time.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFF9F9F9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // If you need the username from UserProvider, fetch it here:
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final username = userProvider.username;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        username: username, // Greet them by name/email
                      ),
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
