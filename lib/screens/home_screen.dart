// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/app_drawer.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triple M Garage')),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    );
  }
}
