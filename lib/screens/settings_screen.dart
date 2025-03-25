import 'package:flutter/material.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';

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
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
            },
          ),
        ],
      ),
    );
  }
}
