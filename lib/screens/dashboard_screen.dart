import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // If you have a 3-dot menu

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  /// Show a confirmation dialog and return true if confirmed.
  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Cancel a single booking with confirmation.
  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
    bool confirmed = await _showConfirmationDialog(
      context,
      "Cancel Booking",
      "Do you really want to cancel this booking?",
    );
    if (!confirmed) return;

    // 1) Delete from Firestore if docId is set
    if (booking.docId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.docId)
          .delete();
    }

    // 2) Remove from local provider
    Provider.of<BookingProvider>(context, listen: false).removeBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reservation cancelled.")),
    );
  }

  /// Cancel all bookings (both current and upcoming) with confirmation.
  Future<void> _cancelAllBookings(BuildContext context) async {
    bool confirmed = await _showConfirmationDialog(
      context,
      "Cancel All Bookings",
      "Do you really want to cancel all your bookings?",
    );
    if (!confirmed) return;

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Prepare a list of all bookings to cancel
    final List bookingList = [];
    if (bookingProvider.currentBooking != null) {
      bookingList.add(bookingProvider.currentBooking);
    }
    bookingList.addAll(bookingProvider.upcomingBookings);

    // Iterate and cancel each booking in Firestore and local provider
    for (var booking in bookingList) {
      if (booking.docId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking.docId)
            .delete();
      }
      bookingProvider.removeBooking(booking);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All reservations cancelled.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currentBooking = bookingProvider.currentBooking;

    // Fetch the user’s current email or name from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.username.isNotEmpty
        ? userProvider.username
        : "User";

    String currentBookingText = "No current booking";
    if (currentBooking != null) {
      currentBookingText = "Slot: ${currentBooking.slotName}\n"
          "Date: ${currentBooking.date}\n"
          "Arrival: ${currentBooking.startTime}\n"
          "Leaving: ${currentBooking.leavingTime}";
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg', // Your logo asset path
              height: 30,       // Adjust the height to make it smaller
            ),
            const SizedBox(width: 8),
            const Text("Dashboard"),
          ],
        ),
        actions: [
          buildOverflowMenu(context), // If you have a 3-dot menu
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName!",
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Bookings
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
                      "Date: ${booking.date}\n"
                          "Arrival: ${booking.startTime}\n"
                          "Leaving: ${booking.leavingTime}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    // Cancel button for each upcoming booking with confirmation
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _cancelBooking(context, booking),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Cancel All Bookings Button (shown if there is at least one booking)
            if (currentBooking != null || bookingProvider.upcomingBookings.isNotEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () => _cancelAllBookings(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Cancel All Bookings"),
                ),
              ),
            const SizedBox(height: 20),

            // Check Availability Button
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
