import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';

class ThankYouScreen extends StatelessWidget {
  final String slotName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final double amount;

  const ThankYouScreen({
    Key? key,
    required this.slotName,
    required this.startDateTime,
    required this.endDateTime,
    required this.amount,
  }) : super(key: key);

  /// Compute days/hours difference
  Map<String, int> _computeDaysHours(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final totalDays = diff.inDays;
    final leftoverHours = diff.inHours % 24;
    return {
      'days': totalDays,
      'hours': leftoverHours,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Format the start/end in a readable way
    final String startFormatted = DateFormat("yyyy-MM-dd h:mm a").format(startDateTime);
    final String endFormatted   = DateFormat("yyyy-MM-dd h:mm a").format(endDateTime);

    // Compute duration
    final duration = _computeDaysHours(startDateTime, endDateTime);
    final days  = duration['days'] ?? 0;
    final hours = duration['hours'] ?? 0;

    String durationText;
    if (days == 0 && hours == 0) {
      durationText = "Less than an hour";
    } else {
      durationText = "$days days and $hours hours";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.jpg',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('Thank You'),
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
              // (Optional) Thank-you image
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'images/thankyou.jpg',
                  height: 150,
                ),
              ),
              const Text(
                'Thank you for your payment!',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFFF9F9F9),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Text(
                'Your parking slot ($slotName) has been booked.\n'
                    'Start: $startFormatted\n'
                    'End:   $endFormatted\n'
                    'Duration: $durationText\n'
                    'Total Cost: £$amount',
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
