import 'package:flutter/material.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/screens/thank_you_screen.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/services/firestore_service.dart';
import 'package:gdp_app/providers/user_provider.dart';

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
              height: 30,        // Adjust the height as needed
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
                onPressed: () async {
                  // Update Firestore on Proceed button click
                  try {
                    final userId = Provider.of<UserProvider>(context, listen: false).username;
                    // Reserve slot in Firestore
                    await FirestoreService().reserveSlot(
                      slotName: slotName,
                      date: date,
                      startTime: startTime,
                      leavingTime: leavingTime,
                      userId: userId,
                    );
                    // Navigate to ThankYouScreen upon successful reservation
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
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                ),
                child: const Text('Confirm'),
              ),
              const SizedBox(height: 10),
              // Cancel Button
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the availability page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
