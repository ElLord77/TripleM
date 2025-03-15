// lib/screens/contact_screen.dart

import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact us')),
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
                // Implement your contact submission logic here
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
