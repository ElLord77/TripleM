// lib/utils/menu_utils.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/home_screen.dart';
import 'package:gdp_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart';

PopupMenuButton<String> buildOverflowMenu(BuildContext context) {
  return PopupMenuButton<String>(
    onSelected: (value) => _onMenuSelected(context, value),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'dashboard',
        child: Text('Dashboard'),
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
    case 'dashboard':
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      break;

    case 'profile':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      break;

    case 'settings':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      break;

    case 'logout':
      _confirmLogout(context);
      break;
  }
}

/// Shows a confirmation dialog before logging out.
Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );

  // If the user confirmed (pressed Yes)
  if (confirmed == true) {
    Provider.of<UserProvider>(context, listen: false).setUsername("");
    Provider.of<UserProvider>(context, listen: false).setUserPassword("");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }
}
