// lib/screens/payment_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/thank_you_screen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final String slotName;
  final String date;
  final String startTime;
  final String leavingTime;
  final double amount;

  const PaymentConfirmationScreen({
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
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.jpg', // Update with your logo asset path
              height: 30,       // Adjust the height as needed
            ),
            const SizedBox(width: 8),
            const Text('Payment Confirmation'),
          ],
        ),
        backgroundColor: const Color(0xFF0F3460),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Payment successful for Slot: $slotName',
                style: const TextStyle(fontSize: 18, color: Color(0xFFF9F9F9)),
              ),
              const SizedBox(height: 10),
              Text(
                'Date: $date\nArrival: $startTime\nLeaving: $leavingTime\nAmount: £$amount',
                style: const TextStyle(fontSize: 16, color: Color(0xFFF9F9F9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThankYouScreen(
                        slotName: slotName,
                        date: date,
                        startTime: startTime,
                        leavingTime: leavingTime,
                        amount: amount,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                ),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
