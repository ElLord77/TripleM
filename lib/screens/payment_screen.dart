// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:gdp_app/screens/payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;

  // We'll parse these 4 strings into two DateTimes
  final String startDate; // e.g. "2023-07-25"
  final String startTime; // e.g. "12:00 PM"
  final String endDate;   // e.g. "2023-07-27"
  final String endTime;   // e.g. "3:00 PM"

  const PaymentScreen({
    Key? key,
    required this.slotName,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Card fields
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  /// Parse date/time into a DateTime
  DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      // dateStr = "yyyy-MM-dd", timeStr = "h:mm a"
      final dateObj = DateFormat("yyyy-MM-dd").parse(dateStr);
      final timeObj = DateFormat("h:mm a").parse(timeStr);
      return DateTime(dateObj.year, dateObj.month, dateObj.day, timeObj.hour, timeObj.minute);
    } catch (e) {
      print("parseDateTime error: $e");
      return null;
    }
  }

  double _computeCost(DateTime start, DateTime end) {
    // If end <= start, add 1 day
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    final diff = end.difference(start);
    final hours = diff.inMinutes / 60.0;
    final cost = hours * 20.0;
    return cost < 0 ? 0.0 : cost;
  }

  void _onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      cardNumber = data.cardNumber;
      expiryDate = data.expiryDate;
      cardHolderName = data.cardHolderName;
      cvvCode = data.cvvCode;
      isCvvFocused = data.isCvvFocused;
    });
  }

  void _onPayNow() {
    if (_formKey.currentState!.validate()) {
      final startDT = _parseDateTime(widget.startDate, widget.startTime);
      final endDT   = _parseDateTime(widget.endDate, widget.endTime);

      if (startDT == null || endDT == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not parse date/time.")),
        );
        return;
      }

      // Compute cost
      final cost = _computeCost(startDT, endDT);

      // Go to PaymentConfirmation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            slotName: widget.slotName,
            startDateTime: startDT,
            endDateTime: endDT,
            cost: cost,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text(
              'Payment Method',
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Credit Card Widget
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 320,
                height: 200,
                child: Stack(
                  children: [
                    CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                      cardBgColor: const Color(0xFFC0C0C0),
                      obscureCardNumber: false,
                      obscureCardCvv: false,
                      isHolderNameVisible: true,
                      onCreditCardWidgetChange: (brand) {},
                    ),
                    const Positioned(
                      top: 20,
                      right: 30,
                      child: Text(
                        'business',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Credit Card Form
            CreditCardForm(
              formKey: _formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: _onCreditCardModelChange,
              obscureCvv: false,
              obscureNumber: false,
              inputConfiguration: const InputConfiguration(
                cardNumberDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                ),
                expiryDateDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Expired Date',
                  hintText: 'XX/XX',
                ),
                cvvCodeDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                cardHolderDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Card Holder',
                ),
                cardNumberTextStyle: TextStyle(fontSize: 16, color: Colors.white),
                cardHolderTextStyle: TextStyle(fontSize: 16, color: Colors.white),
                expiryDateTextStyle: TextStyle(fontSize: 16, color: Colors.white),
                cvvCodeTextStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _onPayNow,
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
