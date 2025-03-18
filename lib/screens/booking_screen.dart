// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String slotName;

  const BookingScreen({
    Key? key,
    required this.slotName,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _leavingTimeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _startTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectLeavingTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _leavingTimeController.text = picked.format(context);
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

            // START TIME
            TextField(
              controller: _startTimeController,
              decoration: InputDecoration(
                labelText: 'Arrival Time',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectStartTime(context),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // LEAVING TIME
            TextField(
              controller: _leavingTimeController,
              decoration: InputDecoration(
                labelText: 'Leaving Time',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectLeavingTime(context),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                double paymentAmount = 0.0; // We'll compute in PaymentScreen

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      slotName: widget.slotName,
                      date: _dateController.text,
                      startTime: _startTimeController.text,
                      leavingTime: _leavingTimeController.text,
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
