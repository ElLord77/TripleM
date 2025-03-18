// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/screens/payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;
  final String date;
  final String startTime;
  final String leavingTime;
  final double amount; // base or fallback amount

  const PaymentScreen({
    Key? key,
    required this.slotName,
    required this.date,
    required this.startTime,
    required this.leavingTime,
    required this.amount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  double _calculatedCost = 0.0;

  @override
  void initState() {
    super.initState();
    _calculatedCost = computeParkingCost(widget.startTime, widget.leavingTime);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  DateTime? parseTime(String timeString) {
    // For 12-hour format like "10:00 AM"
    try {
      final format = DateFormat.jm();
      return format.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  double computeParkingCost(String startTime, String leavingTime) {
    final start = parseTime(startTime);
    final leave = parseTime(leavingTime);
    if (start == null || leave == null) return widget.amount;

    final diff = leave.difference(start);
    final hours = diff.inMinutes / 60.0;

    // 1 hr => 20 pounds
    // partial hours => partial cost
    double cost = hours * 20.0;
    if (cost < 0) cost = 0.0; // if user sets leaving before arrival
    return cost;
  }

  void _onPayNow() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing payment...')),
      );

      // Create a booking
      final booking = Booking(
        slotName: widget.slotName,
        date: widget.date,
        startTime: widget.startTime,
        leavingTime: widget.leavingTime,
      );

      Provider.of<BookingProvider>(context, listen: false).addBooking(booking);

      // Navigate to PaymentConfirmationScreen, pass the computed cost
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            slotName: widget.slotName,
            date: widget.date,
            startTime: widget.startTime,
            leavingTime: widget.leavingTime,
            amount: _calculatedCost,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text('Payment Method', style: TextStyle(color: Color(0xFFF9F9F9))),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Example credit card display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('business', style: TextStyle(fontSize: 16, color: Colors.white54)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2221 0012 3412 3456', style: TextStyle(fontSize: 20, letterSpacing: 2, color: Colors.white)),
                        SizedBox(width: 40, height: 30),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('12/23      Lee M. Cardholder', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card Number
              _buildTextField(_cardNumberController, 'Enter card no.', 'xxxx xxxx xxxx xxxx'),
              const SizedBox(height: 15),

              // Card Holder
              _buildTextField(_cardHolderNameController, "Enter card Holder's Name", 'Enter Your Name'),
              const SizedBox(height: 15),

              // Expiry & CVV
              Row(
                children: [
                  Expanded(child: _buildTextField(_expiryDateController, 'Expire date:', 'MM/YY')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_cvvController, 'CVV:', '123', obscureText: true)),
                ],
              ),
              const SizedBox(height: 20),

              // Pay Now
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _onPayNow,
                  child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),

              // Booking summary
              Text(
                'Slot: ${widget.slotName}'
                    '\nDate: ${widget.date}'
                    '\nArrival: ${widget.startTime}'
                    '\nLeaving: ${widget.leavingTime}'
                    '\nCost: £${_calculatedCost.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint, {
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: obscureText ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFF5733)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please fill out this field';
        }
        return null;
      },
    );
  }
}
