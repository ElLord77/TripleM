// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/availability_screen.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              obscureText: true,
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AvailabilityScreen()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
