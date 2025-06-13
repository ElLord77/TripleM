// lib/screens/contact_review_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your providers and screens
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/home_screen.dart'; // or wherever your home is

class ContactReviewScreen extends StatelessWidget {
  final String name;
  final String email;
  final String message;

  const ContactReviewScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if user is signed in by checking userProvider
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Your Message"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display user’s input
              Text(
                "Name: $name\nEmail: $email\nMessage: $message",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Thank-you text
              const Text(
                "Thank you, we have received your message\n"
                    "and we will contact you soon.\nHave a nice day!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OK Button
              ElevatedButton(
                onPressed: () {
                  // If user is signed in, go to Dashboard
                  if (userProvider.username.isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()),
                    );
                  } else {
                    // If not signed in, go to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
