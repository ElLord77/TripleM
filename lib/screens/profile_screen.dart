// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdp_app/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // For the password change fields
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _fullNameController = TextEditingController(text: userProvider.fullName);
    _emailController = TextEditingController(text: userProvider.username);
    _phoneController = TextEditingController(text: userProvider.phoneNumber);
    _addressController = TextEditingController(text: userProvider.address);
    // If you have phone/address in your provider, populate them here
    // e.g., _phoneController.text = userProvider.phoneNumber;
    // _addressController.text = userProvider.address;_
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Save basic profile info
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.setFullName(_fullNameController.text.trim());
      userProvider.setUsername(_emailController.text.trim());
      userProvider.setPhoneNumber(_phoneController.text.trim());
      userProvider.setAddress(_addressController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile info updated successfully!")),
      );
    }
  }

  // Change the password after verifying current password
  void _changePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Verify current password
      if (_currentPasswordController.text.trim() != userProvider.userPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect current password.")),
        );
        return;
      }

      // Check new password == confirm password
      if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match.")),
        );
        return;
      }

      // Update user password
      userProvider.setUserPassword(_newPasswordController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully!")),
      );

      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF16213E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Basic Profile Form
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Edit Profile Info",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Full Name
                      TextFormField(
                        controller: _fullNameController,
                        decoration: _buildInputDecoration("Full Name"),
                        style: const TextStyle(color: Colors.white),
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
                        decoration: _buildInputDecoration("Email"),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: _buildInputDecoration("Phone Number"),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: _buildInputDecoration("Address"),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.streetAddress,
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Save Profile Info"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Change Password Section
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Current Password
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: _buildInputDecoration("Current Password"),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your current password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // New Password
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: _buildInputDecoration("New Password"),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a new password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Confirm New Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: _buildInputDecoration("Confirm New Password"),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your new password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Change Password Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Update Password"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE94560)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
