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

    final ThemeData theme = Theme.of(context); // Get the current theme
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text('Dashboard'), // AppBar title text will use AppBarTheme
          ],
        ),
        actions: [
          buildOverflowMenu(context), // Assuming this is correctly implemented
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
                      Icons.person,
                      color: isDarkMode
                          ? Colors.white
                          : theme.colorScheme.primary,
                      size: 28
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Welcome, $displayName!',
                    // Apply a style that's prominent but uses theme colors
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      // Color is inherited from theme.textTheme.headlineSmall
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start, // Ensures buttons align to start
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Check Availability'),
                  style: ElevatedButton.styleFrom(
                    // Removed hardcoded backgroundColor to use theme's ElevatedButtonTheme
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
                  icon: const Icon(Icons.person),
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
                  icon: const Icon(Icons.settings),
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
                  icon: const Icon(Icons.payment),
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
                // Card color will now be determined by the theme's cardTheme or surfaceColor
                // Removed: color: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isDarkMode ? 2 : 4, // Slightly different elevation for visual depth
                child: ListTile(
                  leading: Icon(
                    Icons.support_agent,
                    // Icon color will be inherited from theme's listTileTheme.iconColor or iconTheme.color
                  ),
                  title: const Text(
                    'Contact Us',
                    style: TextStyle(fontWeight: FontWeight.bold), // Color inherited
                  ),
                  subtitle: const Text(
                    'Need help or have questions? Get in touch.', // Color inherited
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
    );
  }
}
