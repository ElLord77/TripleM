// lib/screens/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';
import 'package:gdp_app/screens/contact_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0F3460)),
            child: Text(
              'Triple M Garage',
              style: TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
            ),
          ),
          ListTile(
            title: Text('Sign in', style: TextStyle(color: Color(0xFFF9F9F9))),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            ),
          ),
          ListTile(
            title: Text('Registration', style: TextStyle(color: Color(0xFFF9F9F9))),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            ),
          ),
          ListTile(
            title: Text('Contact us', style: TextStyle(color: Color(0xFFF9F9F9))),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
