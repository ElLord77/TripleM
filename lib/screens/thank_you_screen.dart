// lib/screens/thank_you_screen.dart
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
    final ThemeData theme = Theme.of(context); // Get current theme
    final TextTheme textTheme = theme.textTheme;

    final String startFormatted = DateFormat("yyyy-MM-dd h:mm a").format(
        startDateTime);
    final String endFormatted = DateFormat("yyyy-MM-dd h:mm a").format(
        endDateTime);

    final duration = _computeDaysHours(startDateTime, endDateTime);
    final days = duration['days'] ?? 0;
    final hours = duration['hours'] ?? 0;

    String durationText;
    if (days == 0 && hours == 0) {
      durationText = "Less than an hour";
    } else {
      durationText = "$days days and $hours hours";
    }

    return Scaffold(
      // backgroundColor will be inherited from theme.scaffoldBackgroundColor
      // backgroundColor: const Color(0xFF1A1A2E), // Removed
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
            const Text('Thank You'), // Text color from AppBarTheme
          ],
        ),
        // backgroundColor will be inherited from theme.appBarTheme.backgroundColor
        // backgroundColor: const Color(0xFF0F3460), // Removed
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'images/thankyou.jpg',
                  // Ensure this image looks good on both light/dark backgrounds
                  height: 150,
                ),
              ),
              Text(
                'Thank you for your payment!',
                // Removed explicit color, will use theme's textTheme
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Text(
                'Your parking slot ($slotName) payment has been confirmed.\n' // Updated text slightly
                    'Start: $startFormatted\n'
                    'End:   $endFormatted\n'
                    'Duration: $durationText\n'
                    'Total Cost: £${amount.toStringAsFixed(2)}',
                // Or use your currency symbol
                // Removed explicit color, will use theme's textTheme
                style: textTheme.bodyLarge?.copyWith(height: 1.5),
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
                // Style will come from theme.elevatedButtonTheme
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: const Color(0xFFFF5733), // Removed
                // ),
                child: const Text(
                    'Go Back to Dashboard'), // Text color from ElevatedButtonTheme
              ),
            ],
          ),
        ),
      ),
    );
  }
}
