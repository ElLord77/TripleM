// lib/screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Import your providers and destination screens
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/providers/booking_provider.dart';
import 'package:gdp_app/services/firestore_service.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';
import 'package:gdp_app/screens/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for email/password fields
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1) Sign in with FirebaseAuth
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2) Get the signed-in user's actual email (avoid using doc['email']).
        final actualEmail = userCredential.user?.email ?? _emailController.text.trim();

        // 3) Update the UserProvider with the actual email.
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUsername(actualEmail);

        // 4) Fetch user profile from /users/{email} (if it exists) and update provider
        final profileData = await FirestoreService().getUserProfileByEmail(actualEmail);
        if (profileData != null) {
          userProvider.setFullName(profileData['fullName'] ?? '');
          userProvider.setPhoneNumber(profileData['phoneNumber'] ?? '');
          userProvider.setAddress(profileData['address'] ?? '');
          // If you store the email field in that doc as well:
          // userProvider.setUsername(profileData['email'] ?? actualEmail);
        }

        // 5) Fetch bookings from Firestore for this user (using the actualEmail).
        final bookings = await FirestoreService().getBookings(userEmail: actualEmail);

        // 6) Update the BookingProvider with the fetched bookings
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        bookingProvider.clearBookings();
        for (var booking in bookings) {
          bookingProvider.addBooking(booking);
        }

        // 7) Navigate to DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );

      } on FirebaseAuthException catch (e) {
        // If sign in fails (e.g., wrong password, user not found)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error during sign in')),
        );
      } catch (e) {
        // Any other error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

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
            const Text("Sign In"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo Section
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'images/logo.jpg', // Ensure this path matches your asset
                height: 120,
              ),
            ),
            // Sign In Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onSignIn,
                      child: const Text("Sign In"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Forgot Password and Register Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Forgot Password Button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                      // Register Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text("New User? Register"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
