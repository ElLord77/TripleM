// lib/screens/payment_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/providers/user_provider.dart';
// import 'package:gdp_app/services/firestore_service.dart'; // FirestoreService might not be needed if updating directly
import 'package:gdp_app/screens/thank_you_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String slotName; // Still useful for display
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String documentId; // <-- This parameter is required

  const PaymentConfirmationScreen({
    Key? key,
    required this.slotName,
    required this.startDateTime,
    required this.endDateTime,
    required this.documentId, // <-- Make sure this is in your constructor
  }) : super(key: key);

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessing = false;
  bool _isLoadingFee = true;
  double? _fetchedFee;

  @override
  void initState() {
    super.initState();
    _fetchParkingFeeAndDetails();
  }

  Future<void> _fetchParkingFeeAndDetails() async {
    if (!mounted) return;
    setState(() { _isLoadingFee = true; });

    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('parking_records')
          .doc(widget.documentId) // Use documentId to fetch the specific record
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('fee')) {
          if (mounted) {
            setState(() {
              _fetchedFee = (data['fee'] ?? 0.0).toDouble();
            });
          }
        } else {
          throw Exception('Fee not found in parking record.');
        }
      } else {
        throw Exception('Parking record not found with ID: ${widget.documentId}');
      }
    } catch (e) {
      print('Error fetching fee: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching payment details: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingFee = false; });
      }
    }
  }

  Map<String, int> _computeDaysHours(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return { 'days': diff.inDays, 'hours': diff.inHours % 24, };
  }

  Future<void> _confirmPaymentAndUpdateRecord() async {
    if (_fetchedFee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount not loaded yet. Please wait.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      // final userEmail = Provider.of<UserProvider>(context, listen: false).username; // May not be needed here

      // Update the existing parking record to mark it as paid
      await FirebaseFirestore.instance
          .collection('parking_records')
          .doc(widget.documentId) // Use the documentId passed to this screen
          .update({
        'status': 'paid', // Or your desired status for a paid record
        'payment_timestamp': FieldValue.serverTimestamp(),
        // You can add other payment-related details here, e.g., transactionId
      });

      // Navigate to Thank You screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(
            slotName: widget.slotName,
            startDateTime: widget.startDateTime,
            endDateTime: widget.endDateTime,
            amount: _fetchedFee!,
          ),
        ),
      );
    } catch (e) {
      print("Error during payment confirmation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment confirmation failed: ${e.toString()}')),
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
        automaticallyImplyLeading: false, // Or true if you want a back button
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
        child: _isLoadingFee
            ? const CircularProgressIndicator()
            : _fetchedFee == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Could not load payment details.', style: TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchParkingFeeAndDetails, child: const Text('Retry')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
          ],
        )
            : Padding(
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
                    'Cost: £${_fetchedFee!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Color(0xFFF9F9F9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPaymentAndUpdateRecord, // Call updated method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                      : const Text('Confirm Payment'), // Updated button text
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
                    Navigator.pushReplacement( // Or pop until dashboard
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(), // Ensure DashboardScreen is imported
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
