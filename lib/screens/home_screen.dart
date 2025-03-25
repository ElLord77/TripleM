import 'package:flutter/material.dart';
import 'package:gdp_app/screens/app_drawer.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.jpg', // Your logo asset path
              height: 30,         // Adjust the height as needed
            ),
            const SizedBox(width: 8),
            const Text('Triple M Garage'),
          ],
        ),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section in the body
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'images/logo.jpg', // Ensure this path matches your asset
                  height: 120,        // Adjust height as desired
                ),
              ),
              const Text(
                'Welcome to our garage',
                style: TextStyle(fontSize: 20, color: Color(0xFFF9F9F9)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                ),
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
