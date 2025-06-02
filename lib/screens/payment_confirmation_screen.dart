// lib/screens/payment_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Keep if UserProvider is still needed for userEmail
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/providers/user_provider.dart'; // Keep if used
import 'package:gdp_app/screens/thank_you_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String slotName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String documentId;

  const PaymentConfirmationScreen({
    Key? key,
    required this.slotName,
    required this.startDateTime,
    required this.endDateTime,
    required this.documentId,
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
          .doc(widget.documentId)
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
      // final userEmail = Provider.of<UserProvider>(context, listen: false).username; // If needed for logging or receipt

      await FirebaseFirestore.instance
          .collection('parking_records')
          .doc(widget.documentId)
          .update({
        'status': 'paid',
        'payment_timestamp': FieldValue.serverTimestamp(),
      });

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
    final ThemeData theme = Theme.of(context); // Get current theme
    final TextTheme textTheme = theme.textTheme;

    final duration = _computeDaysHours(widget.startDateTime, widget.endDateTime);
    final days = duration['days']!;
    final hours = duration['hours']!;
    final durationText = (days == 0 && hours == 0)
        ? 'Less than an hour'
        : '$days days and $hours hours';

    final startFmt = DateFormat('yyyy-MM-dd h:mm a').format(widget.startDateTime);
    final endFmt = DateFormat('yyyy-MM-dd h:mm a').format(widget.endDateTime);

    return Scaffold(
      // backgroundColor will be inherited from theme.scaffoldBackgroundColor
      // backgroundColor: const Color(0xFF1A1A2E), // Removed
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text('Payment Confirmation'), // Text color from AppBarTheme
          ],
        ),
        // backgroundColor will be inherited from theme.appBarTheme.backgroundColor
        // backgroundColor: const Color(0xFF0F3460), // Removed
        centerTitle: true,
      ),
      body: Center(
        child: _isLoadingFee
            ? const CircularProgressIndicator()
            : _fetchedFee == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Could not load payment details.', style: TextStyle(color: theme.colorScheme.error, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchParkingFeeAndDetails, child: const Text('Retry')),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')), // TextButton uses theme
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Booking Slot: ${widget.slotName}',
                style: textTheme.titleLarge, // Use theme's text style
              ),
              const SizedBox(height: 10),
              Text(
                'Start: $startFmt\n'
                    'End:   $endFmt\n'
                    'Duration: $durationText\n'
                // Using bodyMedium for details, and titleMedium for cost
                    'Cost: £${_fetchedFee!.toStringAsFixed(2)}',
                style: textTheme.bodyMedium?.copyWith(height: 1.5), // Added line height
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPaymentAndUpdateRecord,
                  // Style will come from theme.elevatedButtonTheme
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: const Color(0xFFFF5733), // Removed
                  // ),
                  child: _isProcessing
                      ? const SizedBox(
                    width: 24, height: 24, // Constrain size
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white), // Or use theme.colorScheme.onPrimary
                      strokeWidth: 2.0,
                    ),
                  )
                      : const Text('Confirm Payment'),
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
                  // Use a less prominent style for Cancel, or theme's default
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.12), // Example for a secondary action
                    foregroundColor: theme.colorScheme.onSurface, // Text color for this button
                  ),
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
