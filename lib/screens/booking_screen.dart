// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String slotName;

  BookingScreen({required this.slotName});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

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
      appBar: AppBar(title: Text('Booking - ${widget.slotName}')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Book your space: ${widget.slotName}',
              style: TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter date',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectDate(context),
                ),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Enter time',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectTime(context),
                ),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to PaymentScreen with chosen date/time
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      slotName: widget.slotName,
                      date: _dateController.text,
                      time: _timeController.text,
                    ),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
