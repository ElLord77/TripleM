// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart';
import 'package:gdp_app/screens/settings_screen.dart';
import 'package:gdp_app/screens/contact_us_screen.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // Optional overflow menu
// Import for the new PayParkingScreen (create this file next)
import 'package:gdp_app/screens/pay_parking_screen.dart';


// ArabicNumbersInputFormatter and Firestore logic will be moved to PayParkingScreen
// If ArabicNumbersInputFormatter is used elsewhere, keep it in a shared utils file.

class DashboardScreen extends StatelessWidget { // Changed to StatelessWidget
  const DashboardScreen({Key? key}) : super(key: key);

  // Dialog and fetching logic removed from here

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.fullName.isNotEmpty
        ? userProvider.fullName
        : 'User';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          buildOverflowMenu(context),
        ],
      ),
      body: SingleChildScrollView( // Removed Stack as _isLoading is removed
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white12,
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Welcome, $displayName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Check Availability'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailabilityScreen(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
                // --- Updated Pay Here Button ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Here'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5F7A), // Slightly different color for distinction
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PayParkingScreen()),
                    );
                  },
                ),
                // ------------------------------
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.support_agent, color: Colors.white),
                  title: const Text(
                    'Contact Us',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Need help or have questions? Get in touch.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Removed loading indicator overlay as _isLoading is removed
    );
  }
}
