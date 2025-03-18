// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // If you have a 3-dot menu
import 'package:gdp_app/providers/user_provider.dart'; // If you need userPassword from here

class DashboardScreen extends StatelessWidget {
  final String username;
  final String userPassword;

  const DashboardScreen({
    Key? key,
    this.username = "User",
    required this.userPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currentBooking = bookingProvider.currentBooking;

    String currentBookingText = currentBooking != null
        ? "Slot: ${currentBooking.slotName}\nDate: ${currentBooking.date}\nTime: ${currentBooking.time}"
        : "No current booking";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          // If you're using a 3-dot menu:
          buildOverflowMenu(context),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $username!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Current Booking Card
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentBookingText,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.white),
                    title: Text(
                      "Slot: ${booking.slotName}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Date: ${booking.date}\nTime: ${booking.time}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    // Cancel a specific booking
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        // Prompt for password before canceling
                        _showCancelBookingDialog(context, booking);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Example Quick Access or other UI
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AvailabilityScreen()),
                  );
                },
                child: const Text("Check Availability"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a dialog to confirm password before canceling
  void _showCancelBookingDialog(BuildContext context, Booking booking) {
    final TextEditingController _cancelPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Booking"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your password to cancel this booking:"),
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
                // Check if password matches the user's password
                if (_cancelPasswordController.text.trim() == userPassword.trim()) {
                  // Cancel only the selected booking
                  Provider.of<BookingProvider>(context, listen: false).removeBooking(booking);

                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Booking cancelled.")),
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
