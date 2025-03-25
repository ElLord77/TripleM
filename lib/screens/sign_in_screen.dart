// lib/screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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

        // 2) Get the current user's UID
        final uid = userCredential.user!.uid;

        // 3) Fetch the user doc from /users/{uid}
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!userDoc.exists) {
          throw Exception("User document not found in Firestore.");
        }

        final data = userDoc.data() as Map<String, dynamic>?;

        // 4) If userDoc has 'fullName' and 'email', store them in UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Firestore doc might have: { "fullName": "John Doe", "email": "johndoe@example.com", ... }
        final firestoreFullName = data?['fullName'] ?? '';
        final firestoreEmail    = data?['email'] ?? '';

        userProvider.setFullName(firestoreFullName);
        userProvider.setUsername(firestoreEmail);

        // 5) If you store bookings by userEmail in Firestore, fetch them:
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        bookingProvider.clearBookings();

        if (firestoreEmail.isNotEmpty) {
          // Example: getBookings by userEmail
          final bookings = await FirestoreService().getBookings(userEmail: firestoreEmail);
          for (var booking in bookings) {
            bookingProvider.addBooking(booking);
          }
        }

        // 6) Navigate to DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error during sign in')),
        );
      } catch (e) {
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
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text("Sign In"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'images/logo.jpg',
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

                  // Forgot Password / Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
