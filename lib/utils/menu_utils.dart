// lib/utils/menu_utils.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart'; // If you have a ProfileScreen

/// Returns a PopupMenuButton for the overflow menu
/// with items: Home (Dashboard), Profile, Settings, and Logout.
PopupMenuButton<String> buildOverflowMenu(BuildContext context) {
  return PopupMenuButton<String>(
    onSelected: (value) => _onMenuSelected(context, value),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'home',
        child: Text('Home'),
      ),
      const PopupMenuItem<String>(
        value: 'profile',
        child: Text('Profile'),
      ),
      const PopupMenuItem<String>(
        value: 'settings',
        child: Text('Settings'),
      ),
      const PopupMenuItem<String>(
        value: 'logout',
        child: Text('Logout'),
      ),
    ],
  );
}

void _onMenuSelected(BuildContext context, String value) {
  switch (value) {
    case 'home':
      _goToDashboard(context);
      break;

    case 'profile':
      _goToProfile(context);
      break;

    case 'settings':
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings selected.")),
      );
      break;

    case 'logout':
    // Clear user data
      Provider.of<UserProvider>(context, listen: false).setUsername("");
      Provider.of<UserProvider>(context, listen: false).setUserPassword("");

      // Navigate to SignInScreen, removing all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
            (Route<dynamic> route) => false,
      );
      break;
  }
}

void _goToDashboard(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final username = userProvider.username; // greet them by name/email

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardScreen(username: username),
    ),
  );
}

void _goToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
  );
}
