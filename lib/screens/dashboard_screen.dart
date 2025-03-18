// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // If you have a 3-dot menu

class DashboardScreen extends StatelessWidget {
  final String username;

  const DashboardScreen({
    Key? key,
    this.username = "User",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currentBooking = bookingProvider.currentBooking;

    String currentBookingText = "No current booking";
    if (currentBooking != null) {
      currentBookingText = "Slot: ${currentBooking.slotName}\n"
          "Date: ${currentBooking.date}\n"
          "Arrival: ${currentBooking.startTime}\n"
          "Leaving: ${currentBooking.leavingTime}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          buildOverflowMenu(context), // if you have a menu
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $username!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Current Booking
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Booking",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(currentBookingText, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Bookings
            const Text(
              "Upcoming Bookings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.white),
                    title: Text("Slot: ${booking.slotName}", style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      "Date: ${booking.date}\nArrival: ${booking.startTime}\nLeaving: ${booking.leavingTime}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        bookingProvider.removeBooking(booking);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking cancelled.")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Check Availability
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
}
