import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/services/firestore_service.dart';
import 'package:gdp_app/screens/thank_you_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
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

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessing = false;

  /// Compute days/hours difference
  Map<String, int> _computeDaysHours(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return {
      'days': diff.inDays,
      'hours': diff.inHours % 24,
    };
  }

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    try {
      final userEmail = Provider.of<UserProvider>(context, listen: false).username;

      // Reserve slot in Firestore
      await FirestoreService().reserveSlotDateTime(
        slotName: widget.slotName,
        startDateTime: widget.startDateTime,
        endDateTime: widget.endDateTime,
        userEmail: userEmail,
      );

      // Navigate to Thank You screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(
            slotName: widget.slotName,
            startDateTime: widget.startDateTime,
            endDateTime: widget.endDateTime,
            amount: widget.cost,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = _computeDaysHours(widget.startDateTime, widget.endDateTime);
    final days = duration['days']!;
    final hours = duration['hours']!;
    final durationText = (days == 0 && hours == 0)
        ? 'Less than an hour'
        : '$days days and $hours hours';

    final startFmt = DateFormat('yyyy-MM-dd h:mm a').format(widget.startDateTime);
    final endFmt = DateFormat('yyyy-MM-dd h:mm a').format(widget.endDateTime);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
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
                'Booking Slot: ${widget.slotName}',
                style: const TextStyle(fontSize: 18, color: Color(0xFFF9F9F9)),
              ),
              const SizedBox(height: 10),
              Text(
                'Start: $startFmt\n'
                    'End:   $endFmt\n'
                    'Duration: $durationText\n'
                    'Cost: £${widget.cost.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Color(0xFFF9F9F9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                      : const Text('Confirm'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
