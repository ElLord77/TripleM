// lib/screens/contact_us_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your UserProvider, ContactReviewScreen
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/contact_review_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If user is signed in, prefill from UserProvider; otherwise empty
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final inheritedName = userProvider.fullName.isNotEmpty
        ? userProvider.fullName
        : "";
    final inheritedEmail = userProvider.username.isNotEmpty
        ? userProvider.username
        : "";

    _nameController  = TextEditingController(text: inheritedName);
    _emailController = TextEditingController(text: inheritedEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Navigate to ContactReviewScreen, passing the fields
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactReviewScreen(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            message: _messageController.text.trim(),
          ),
        ),
      );
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
            const Text("Contact Us"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
                ),
                style: const TextStyle(color: Color(0xFFF9F9F9)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
                ),
                style: const TextStyle(color: Color(0xFFF9F9F9)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }
                  if (!_isValidEmail(value.trim())) {
                    return "Invalid email format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  labelStyle: TextStyle(color: Color(0xFFF9F9F9)),
                ),
                style: const TextStyle(color: Color(0xFFF9F9F9)),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Message is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
