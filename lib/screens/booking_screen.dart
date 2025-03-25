// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdp_app/screens/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String slotName;

  const BookingScreen({Key? key, required this.slotName}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController   = TextEditingController();
  final TextEditingController _endTimeController   = TextEditingController();

  /// Pick a date, store as "yyyy-MM-dd" in the controller
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final formatted = DateFormat("yyyy-MM-dd").format(picked);
      setState(() {
        controller.text = formatted;
      });
    }
  }

  /// Pick a time, store as "h:mm a" in the controller
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      final localizations = MaterialLocalizations.of(context);
      final formatted = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
      setState(() {
        controller.text = formatted; // e.g. "12:00 PM"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotName = widget.slotName;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg',
              height: 30,
            ),
            const SizedBox(width: 8),
            Text('Booking - $slotName'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Book your space: $slotName',
              style: const TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // START DATE
            TextField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Date',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectDate(context, _startDateController),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // START TIME
            TextField(
              controller: _startTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Time',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectTime(context, _startTimeController),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // END DATE
            TextField(
              controller: _endDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Date',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectDate(context, _endDateController),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // END TIME
            TextField(
              controller: _endTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Time',
                labelStyle: const TextStyle(color: Color(0xFFF9F9F9)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFFF9F9F9)),
                  onPressed: () => _selectTime(context, _endTimeController),
                ),
              ),
              style: const TextStyle(color: Color(0xFFF9F9F9)),
            ),
            const SizedBox(height: 20),

            // BRIEF SUMMARY
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Booking Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9F9F9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Slot: $slotName",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFF9F9F9)),
                  ),
                  Text(
                    "Start Date: ${_startDateController.text.isEmpty ? 'Not set' : _startDateController.text}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFF9F9F9)),
                  ),
                  Text(
                    "Start Time: ${_startTimeController.text.isEmpty ? 'Not set' : _startTimeController.text}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFF9F9F9)),
                  ),
                  Text(
                    "End Date: ${_endDateController.text.isEmpty ? 'Not set' : _endDateController.text}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFF9F9F9)),
                  ),
                  Text(
                    "End Time: ${_endTimeController.text.isEmpty ? 'Not set' : _endTimeController.text}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFF9F9F9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final startDate = _startDateController.text.trim();
                final startTime = _startTimeController.text.trim();
                final endDate   = _endDateController.text.trim();
                final endTime   = _endTimeController.text.trim();

                if (startDate.isEmpty || startTime.isEmpty || endDate.isEmpty || endTime.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select all date/time fields.")),
                  );
                  return;
                }

                // PaymentScreen will parse them into DateTime, compute cost
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      slotName: widget.slotName,
                      startDate: startDate,
                      startTime: startTime,
                      endDate: endDate,
                      endTime: endTime,
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
