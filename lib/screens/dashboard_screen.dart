// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/availability_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart';
import 'package:gdp_app/screens/settings_screen.dart';
import 'package:gdp_app/screens/contact_us_screen.dart';
import 'package:gdp_app/utils/menu_utils.dart'; // Optional overflow menu
// Import for the PayParkingScreen
import 'package:gdp_app/screens/pay_parking_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.fullName.isNotEmpty
        ? userProvider.fullName
        : 'User';

    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Theme-specific icon colors (as previously defined)
    final Color activeIconColor = isDarkMode ? Colors.pink.shade300 : Colors.purple.shade400;
    final Color avatarIconColor = isDarkMode ? Colors.pink.shade200 : Colors.purple.shade600;


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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                      Icons.account_circle,
                      color: avatarIconColor,
                      size: 28
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Welcome, $displayName!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.search, color: activeIconColor),
                  label: const Text('Check Availability'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailabilityScreen(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.person_outline, color: activeIconColor),
                  label: const Text('Profile'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.settings_outlined, color: activeIconColor),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.payment, color: activeIconColor),
                  label: const Text('Pay Here'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PayParkingScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isDarkMode ? 2 : 4,
                child: ListTile(
                  leading: Icon(
                    Icons.support_agent_outlined,
                    color: activeIconColor,
                  ),
                  title: const Text(
                    'Contact Us',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Need help or have questions? Get in touch.',
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
            const SizedBox(height: 40), // Space before the GIF
            // --- GIF Placeholder Section ---
            Center(
              child: Column(
                children: [
                  Text(
                    "LETS'S", // Optional title for the animation
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'images/park.gif', // IMPORTANT: Replace with your actual GIF path
                    height: 150, // Adjust height as needed
                    // width: 200, // Adjust width as needed
                    // You can add a gaplessPlayback: true if your GIF is seamless
                    // gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if the GIF fails to load
                      return Container(
                        height: 150,
                        width: 200, // Provide a width for the container if image fails
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Animation loading...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space after the GIF
            // --- End GIF Placeholder Section ---
          ],
        ),
      ),
    );
  }
}
