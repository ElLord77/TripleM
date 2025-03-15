// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;
  final String date;
  final String time;

  PaymentScreen({
    required this.slotName,
    required this.date,
    required this.time,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

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
              // **Credit Card Display**
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'business',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2221 0012 3412 3456',
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        // **Empty Container for Logo (Add Image Here)**
                        Container(
                          width: 40,
                          height: 30,
                          color: Colors.transparent, // Placeholder for Visa/Mastercard
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '12/23      Lee M. Cardholder',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // **Payment Form Fields**
              _buildTextField(_cardNumberController, 'Enter card no.', 'xxxx xxxx xxxx xxxx'),
              const SizedBox(height: 15),
              _buildTextField(_cardHolderNameController, 'Enter card Holder\'s Name', 'Enter Your Name'),
              const SizedBox(height: 15),

              // **Expiry Date & CVV in Row**
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_expiryDateController, 'Expire date:', 'MM/YY'),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(_cvvController, 'CVV:', '123', obscureText: true),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // **Pay Now Button** (Bright Orange: #FF5733)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _onPayNow,
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // **Slot Information**
              Text(
                'Slot: ${widget.slotName}\nDate: ${widget.date}\nTime: ${widget.time}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // **Reusable TextField Widget**
  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool obscureText = false}) {
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

  void _onPayNow() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing payment...')),
      );
    }
  }
}
