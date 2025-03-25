// lib/screens/contact_screen.dart

import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg', // Your logo asset path
              height: 30, // Adjust the height to make the logo smaller
            ),
            const SizedBox(width: 8),
            const Text("Contact Us"),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Surname',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
              ),
              style: TextStyle(color: Color(0xFFF9F9F9)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement submission logic
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
