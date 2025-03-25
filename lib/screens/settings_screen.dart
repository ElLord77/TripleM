import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/screens/home_screen.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/settings_screen.dart';
import 'package:gdp_app/screens/profile_screen.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

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
            const Text("Settings"),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO: Add logic to change the app's theme
            },
          ),
          // Notifications Toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Add logic to enable/disable notifications
            },
          ),
          // Language Selection
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final selectedLanguage = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Select Language'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 'English');
                        },
                        child: const Text('English'),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 'Spanish');
                        },
                        child: const Text('Spanish'),
                      ),
                      // Add more languages as needed.
                    ],
                  );
                },
              );
              if (selectedLanguage != null) {
                setState(() {
                  _language = selectedLanguage;
                });
                // TODO: Add logic to update the app's language settings.
              }
            },
          ),
          // About Section
          ListTile(
            title: const Text('About'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              // Show a dialog with app information
              showAboutDialog(
                context: context,
                applicationName: 'My App',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.apps),
                children: [
                  const Text('This is a sample app settings screen built using Flutter.'),
                ],
              );
            },
          ),
          // Logout Option
          ListTile(
            title: const Text('Logout'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).setUsername("");
              Provider.of<UserProvider>(context, listen: false).setUserPassword("");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          // Delete Account Option
          ListTile(
            title: const Text('Delete Account'),
            trailing: const Icon(Icons.delete, color: Colors.red),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the account
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount(context);
    }
  }

  /// Deletes the user from Firebase Auth and Firestore
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // 1) Get the current user from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in.");
      }

      final userId = user.uid; // If you store docs at /users/{uid}
      // or final userEmail = user.email; // If you store docs at /users/{email}

      // 2) Cancel all reservations for this user
      // If you store bookings with 'userId' or 'userEmail', find and delete them:
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.email) // or userId
          .get();

      for (var doc in bookingsQuery.docs) {
        await doc.reference.delete();
      }

      // 3) Delete the user doc from /users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // or doc(userEmail)
          .delete();

      // 4) Delete the user from Firebase Auth
      await user.delete();

      // 5) Clear the local provider
      Provider.of<UserProvider>(context, listen: false).setUsername("");
      Provider.of<UserProvider>(context, listen: false).setUserPassword("");

      // 6) Navigate back to sign in screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // If re-auth is needed or any other Auth error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error deleting account.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }
}
