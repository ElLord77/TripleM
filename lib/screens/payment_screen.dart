import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/payment_confirmation_screen.dart';
import 'package:gdp_app/services/firestore_service.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;
  final String date;
  final String startTime;
  final String leavingTime;
  final double amount;

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
  /// The GlobalKey for validating the form inside CreditCardForm (4.x).
  final _formKey = GlobalKey<FormState>();

  /// Fields for real-time credit card display
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  /// Computed parking cost
  double _calculatedCost = 0.0;

  @override
  void initState() {
    super.initState();
    _calculatedCost = _computeParkingCost(widget.startTime, widget.leavingTime);
  }

  /// Parse time string like "10:00 AM" using intl
  DateTime? _parseTime(String timeString) {
    try {
      final format = DateFormat("h:mm a");
      return format.parse(timeString);
    } catch (e) {
      print("parseTime error: $e");
      return null;
    }
  }

  /// Compute cost based on time difference (example: £20/hour)
  double _computeParkingCost(String startTime, String leavingTime) {
    final start = _parseTime(startTime);
    final leave = _parseTime(leavingTime);

    if (start == null || leave == null) return widget.amount;

    final diff = leave.difference(start);
    final hours = diff.inMinutes / 60.0;
    double cost = hours * 20.0;
    if (cost < 0) cost = 0.0;
    return cost;
  }

  /// This callback updates local state whenever the user edits card fields
  void _onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      cardNumber = data.cardNumber;
      expiryDate = data.expiryDate;
      cardHolderName = data.cardHolderName;
      cvvCode = data.cvvCode;
      isCvvFocused = data.isCvvFocused;
    });
  }

  /// Payment action
  Future<void> _onPayNow() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing payment...')),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.username;

      try {
        // Reserve the slot in Firestore
        final docId = await FirestoreService().reserveSlot(
          slotName: widget.slotName,
          date: widget.date,
          startTime: widget.startTime,
          leavingTime: widget.leavingTime,
          userId: userId,
        );

        // Update local booking state
        final booking = Booking(
          docId: docId,
          slotName: widget.slotName,
          date: widget.date,
          startTime: widget.startTime,
          leavingTime: widget.leavingTime,
        );
        Provider.of<BookingProvider>(context, listen: false).addBooking(booking);

        // Navigate to confirmation screen
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Color(0xFFF9F9F9)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 1. Constrain + Scale the card so it never overflows horizontally
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 320, // typical credit card width in px
                child: CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  cardBgColor: const Color(0xFF0F3460),
                  obscureCardNumber: false,
                  obscureCardCvv: false,

                  // In some 4.x versions, you might remove the chip by setting isChipVisible: false
                  // If you get "named parameter not found" errors, remove this line:
                  isChipVisible: false,

                  // 4.x requires a brand callback
                  onCreditCardWidgetChange: (brand) {
                    // no-op
                  },
                  // No custom icons, no brand references
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// 2. CreditCardForm with inputConfiguration (4.x approach)
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

            /// 3. Pay Now button
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
            const SizedBox(height: 20),

            /// 4. Booking summary
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
    );
  }
}
