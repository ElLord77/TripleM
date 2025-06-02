// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart'; // Ensure this package is in pubspec.yaml
// Import the PaymentConfirmationScreen that expects documentId
import 'package:gdp_app/screens/payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final double fee;
  final String documentId;

  const PaymentScreen({
    Key? key,
    required this.slotName,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.fee,
    required this.documentId,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      final dateObj = DateFormat("yyyy-MM-dd").parse(dateStr);
      final timeObj = DateFormat("h:mm a").parse(timeStr);
      return DateTime(dateObj.year, dateObj.month, dateObj.day, timeObj.hour, timeObj.minute);
    } catch (e) {
      print("parseDateTime error: $e");
      return null;
    }
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            slotName: widget.slotName,
            startDateTime: startDT,
            endDateTime: endDT,
            documentId: widget.documentId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final TextStyle formTextStyle = TextStyle(
        fontSize: 16,
        color: theme.textTheme.bodyMedium?.color
    );

    final Color creditCardBackgroundColor = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFD0D0D0);
    final Color creditCardWidgetTextColor = isDarkMode ? Colors.white : Colors.black;

    // Define a general TextStyle for elements on the CreditCardWidget
    final TextStyle cardWidgetTextStyle = TextStyle(
        color: creditCardWidgetTextColor,
        fontSize: 15 // You can adjust this base font size
    );


    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text('Payment Method'),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                "Amount to Pay: £${widget.fee.toStringAsFixed(2)}",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),

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
                      cardBgColor: creditCardBackgroundColor,

                      // Style for the actual data text (card number, expiry, name)
                      // and hopefully the labels if they inherit from this.
                      textStyle: cardWidgetTextStyle,

                      // Removed labelTextColor as it was causing an error
                      // labelTextColor: creditCardWidgetTextColor,

                      obscureCardNumber: false,
                      obscureCardCvv: false,
                      isHolderNameVisible: true,
                      onCreditCardWidgetChange: (brand) {},
                    ),
                    Positioned(
                      top: 20,
                      right: 30,
                      child: Text(
                        'business',
                        style: TextStyle(
                          color: creditCardWidgetTextColor,
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
            CreditCardForm(
              formKey: _formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: _onCreditCardModelChange,
              obscureCvv: false,
              obscureNumber: false,
              inputConfiguration: InputConfiguration(
                cardNumberDecoration: const InputDecoration(
                  labelText: 'Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                ),
                expiryDateDecoration: const InputDecoration(
                  labelText: 'Expired Date',
                  hintText: 'XX/XX',
                ),
                cvvCodeDecoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                cardHolderDecoration: const InputDecoration(
                  labelText: 'Card Holder',
                ),
                cardNumberTextStyle: formTextStyle,
                cardHolderTextStyle: formTextStyle,
                expiryDateTextStyle: formTextStyle,
                cvvCodeTextStyle: formTextStyle,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onPayNow,
                child: const Text(
                  'Pay Now',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
