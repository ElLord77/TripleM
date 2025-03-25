// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController    = TextEditingController();
  final TextEditingController _emailController       = TextEditingController();
  final TextEditingController _phoneController       = TextEditingController();
  final TextEditingController _passwordController    = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _onRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1) Create user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2) Grab the user’s UID
        final uid = userCredential.user!.uid;

        // 3) Store user info in Firestore at /users/{uid}
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'fullName':   _fullNameController.text.trim(),
          'email':      _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'createdAt':  FieldValue.serverTimestamp(),
        });

        // 4) Update UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setFullName(_fullNameController.text.trim());
        userProvider.setUsername(_emailController.text.trim());
        userProvider.setPhoneNumber(_phoneController.text.trim());

        // 5) Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error during registration')),
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
            const Text("Register"),
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
            // Registration Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your full name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      // Optionally add email format validation
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your phone number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: "Confirm Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  ElevatedButton(
                    onPressed: _onRegister,
                    child: const Text("Register"),
                  ),
                  const SizedBox(height: 10),

                  // Already have an account?
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                    child: const Text("Already have an account? Sign In"),
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
