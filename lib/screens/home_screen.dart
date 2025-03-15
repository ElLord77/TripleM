// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/app_drawer.dart';     // <-- Adjust the import path to match your project
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Triple M Garage')),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to our garage',
              style: TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              ),
              child: Text('Sign in'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              ),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
