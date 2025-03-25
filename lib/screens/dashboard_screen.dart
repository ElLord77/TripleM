// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/contact_us_screen.dart';
import 'package:gdp_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart'; // If you have a ProfileScreen
import 'package:gdp_app/utils/menu_utils.dart';       // If you have a 3-dot menu

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  /// Show a confirmation dialog and return true if confirmed.
  Future<bool> _showConfirmationDialog(
      BuildContext context,
      String title,
      String content,
      ) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
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

  /// Cancel all bookings with confirmation.
  Future<void> _cancelAllBookings(BuildContext context) async {
    bool confirmed = await _showConfirmationDialog(
      context,
      "Cancel All Bookings",
      "Do you really want to cancel all your bookings?",
    );
    if (!confirmed) return;

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    // Prepare a list of all bookings to cancel
    final List<Booking> bookingList = [];
    if (bookingProvider.currentBooking != null) {
      bookingList.add(bookingProvider.currentBooking!);
    }
    bookingList.addAll(bookingProvider.upcomingBookings);

    // Iterate and cancel each booking
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

  /// Format date/time
  String _formatDateTime(DateTime dt) {
    return DateFormat("yyyy-MM-dd h:mm a").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currentBooking = bookingProvider.currentBooking;

    // Show user name from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.fullName.isNotEmpty
        ? userProvider.fullName
        : "User";

    // Build text for current booking
    String currentBookingText = "No current booking";
    if (currentBooking != null) {
      final startFmt = _formatDateTime(currentBooking.startDateTime);
      final endFmt   = _formatDateTime(currentBooking.endDateTime);
      currentBookingText = "Slot: ${currentBooking.slotName}\n"
          "Start: $startFmt\n"
          "End:   $endFmt";
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg',
              height: 30,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1) Greeting with Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white12,
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 10),
                // Let name wrap to multiple lines if it's long
                Expanded(
                  child: Text(
                    "Welcome, $displayName!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2) Quick Action Shortcuts in a Wrap to prevent overflow
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                // Availability Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text("Availability"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // more pill-like
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AvailabilityScreen()),
                    );
                  },
                ),
                // Profile Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text("Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // more pill-like
                    ),
                  ),
                  onPressed: () {
                    // Example if you have a ProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                // Settings Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text("Settings"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // more pill-like
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3) Current Booking
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

            // 4) Upcoming Bookings
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
                final startFmt = _formatDateTime(booking.startDateTime);
                final endFmt   = _formatDateTime(booking.endDateTime);

                final bookingText = "Slot: ${booking.slotName}\n"
                    "Start: $startFmt\n"
                    "End:   $endFmt";

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
                      bookingText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _cancelBooking(context, booking),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // (Optional) Stats or Ended Bookings
            /*
            Card(
              color: Colors.white10,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text("Booking Stats", style: TextStyle(color: Colors.white)),
                subtitle: const Text(
                  "Total Bookings: 5\nThis Month’s Spent: £100",
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  // navigate to a stats page if needed
                },
              ),
            ),
            */

            // Cancel All if there's at least one booking
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

            // 5) Contact Us Section
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            "Contact Us",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Need help or have questions? Get in touch with our support team.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ContactScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6) Check Availability
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AvailabilityScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Check Availability"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
