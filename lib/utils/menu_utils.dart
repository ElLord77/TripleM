// lib/utils/menu_utils.dart

import 'package:flutter/material.dart';
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
      // Navigate to the ProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
      break;

    case 'settings':

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
      break;


    case 'logout':
      Provider.of<UserProvider>(context, listen: false).setUsername("");
      Provider.of<UserProvider>(context, listen: false).setUserPassword("");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (Route<dynamic> route) => false,
      );
      break;
  }
}
