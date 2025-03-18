// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String username;
  final String userPassword; // Password passed from sign in/register

  const DashboardScreen({
    Key? key,
    this.username = "User",
    required this.userPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    String currentBookingText = bookingProvider.currentBooking != null
        ? "Slot: ${bookingProvider.currentBooking!.slotName}\nDate: ${bookingProvider.currentBooking!.date}\nTime: ${bookingProvider.currentBooking!.time}"
        : "No current booking";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Text(
              "Welcome, $username!",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Current Booking Details Card
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Booking",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentBookingText,
                      style:
                      const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Upcoming Bookings Section
            const Text(
              "Upcoming Bookings",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookingProvider.upcomingBookings.length,
              itemBuilder: (context, index) {
                final booking = bookingProvider.upcomingBookings[index];
                return Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading:
                    const Icon(Icons.calendar_today, color: Colors.white),
                    title: Text("Slot: ${booking.slotName}",
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text("Date: ${booking.date}\nTime: ${booking.time}",
                        style: const TextStyle(color: Colors.white70)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Quick Access Section
            const Text(
              "Quick Access",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAccessButton(context, Icons.person, "Profile"),
                _buildQuickAccessButton(context, Icons.settings, "Settings"),
                _buildQuickAccessButton(context, Icons.help_outline, "Help"),
              ],
            ),
            const SizedBox(height: 30),
            // Navigation Buttons
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailabilityScreen(),
                    ),
                  );
                },
                child: const Text("Check Availability"),
              ),
            ),
            const SizedBox(height: 20),
            // Cancel Reservation Button
            Center(
              child: ElevatedButton(
                onPressed: () => _showCancelReservationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Cancel Reservation"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
      BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white10,
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  void _showCancelReservationDialog(BuildContext context) {
    final TextEditingController _cancelPasswordController =
    TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Reservation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please enter your password to confirm cancellation:"),
              TextField(
                controller: _cancelPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                print('Entered: "${_cancelPasswordController.text.trim()}"');
                print('Stored: "${userPassword.trim()}"');

                if (_cancelPasswordController.text.trim() == userPassword.trim()) {
                  Provider.of<BookingProvider>(context, listen: false)
                      .clearBookings();
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reservation cancelled.")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect password.")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
