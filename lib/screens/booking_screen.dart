// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/payment_screen.dart'; // PaymentScreen collects CC data

class BookingScreen extends StatefulWidget {
  final String slotName;

  const BookingScreen({Key? key, required this.slotName}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking - ${widget.slotName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Book your space: ${widget.slotName}',
              style: const TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),
            // DATE
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter date',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectDate(context),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),
            // TIME
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Enter time',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectTime(context),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // SUBMIT -> PaymentScreen
            ElevatedButton(
              onPressed: () {
                // Example: pass a fixed payment amount
                double paymentAmount = 15.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      slotName: widget.slotName,
                      date: _dateController.text,
                      time: _timeController.text,
                      amount: paymentAmount,
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
