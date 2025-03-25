// lib/screens/payment_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/screens/thank_you_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/services/firestore_service.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final String slotName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final double cost;

  const PaymentConfirmationScreen({
    Key? key,
    required this.slotName,
    required this.startDateTime,
    required this.endDateTime,
    required this.cost,
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
    // Duration
    final bookingDuration = _computeDaysHours(startDateTime, endDateTime);
    final days = bookingDuration['days'] ?? 0;
    final hours = bookingDuration['hours'] ?? 0;
    final durationText = (days == 0 && hours == 0)
        ? "Less than an hour"
        : "$days days and $hours hours";

    // Format date/time
    final startFmt = DateFormat("yyyy-MM-dd h:mm a").format(startDateTime);
    final endFmt   = DateFormat("yyyy-MM-dd h:mm a").format(endDateTime);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.jpg', height: 30),
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
                'You are booking Slot: $slotName',
                style: const TextStyle(fontSize: 18, color: Color(0xFFF9F9F9)),
              ),
              const SizedBox(height: 10),
              Text(
                'Start: $startFmt\n'
                    'End: $endFmt\n'
                    'Duration: $durationText\n'
                    'Cost: £$cost',
                style: const TextStyle(fontSize: 16, color: Color(0xFFF9F9F9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // 1) Get user email from provider
                    final userEmail = Provider.of<UserProvider>(context, listen: false).username;

                    // 2) Reserve slot in Firestore
                    final docId = await FirestoreService().reserveSlotDateTime(
                      slotName: slotName,
                      startDateTime: startDateTime,
                      endDateTime: endDateTime,
                      userEmail: userEmail,
                    );

                    // 3) Add to local BookingProvider
                    if (docId.isNotEmpty) {
                      final newBooking = Booking(
                        docId: docId,
                        slotName: slotName,
                        startDateTime: startDateTime,
                        endDateTime: endDateTime,
                      );
                      Provider.of<BookingProvider>(context, listen: false).addBooking(newBooking);
                    }

                    // 4) Navigate to ThankYouScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThankYouScreen(
                          slotName: slotName,
                          startDateTime: startDateTime,
                          endDateTime: endDateTime,
                          amount: cost,
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
