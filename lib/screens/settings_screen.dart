// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:provider/provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Keep as local state for now or move to a provider
  String _language = 'English'; // Placeholder, will be driven by LocaleProvider later

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final localeProvider = Provider.of<LocaleProvider>(context); // For when you implement language
    // final localizations = AppLocalizations.of(context)!; // For when you implement language

    // Placeholder for localized strings until full localization setup
    String settingsTitle = "Settings";
    String darkModeText = "Dark Mode";
    String enableNotificationsText = "Enable Notifications";
    String languageText = "Language";
    String aboutText = "About";
    String logoutText = "Logout";
    String deleteAccountText = "Delete Account";
    // String selectLanguageTitle = "Select Language";
    // String englishText = "English";
    // String spanishText = "Spanish";


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg',
              height: 30,
            ),
            const SizedBox(width: 8),
            Text(settingsTitle),
          ],
        ),
        // actions: [ // Assuming buildOverflowMenu is defined elsewhere and uses context
        //   if (MenuUtils.isMenuAvailable) buildOverflowMenu(context),
        // ],
      ),
      body: ListView(
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: Text(darkModeText),
            value: themeProvider.isDarkMode, // Get current state from provider
            onChanged: (bool value) {
              // Call provider method to change theme
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          // Notifications Toggle
          SwitchListTile(
            title: Text(enableNotificationsText),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Add logic to enable/disable notifications (e.g., using Firebase Messaging)
            },
            secondary: const Icon(Icons.notifications),
          ),
          // Language Selection
          ListTile(
            title: Text(languageText),
            subtitle: Text(_language), // This will be updated by LocaleProvider later
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              // final selectedLocale = await showDialog<Locale>(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return SimpleDialog(
              //       title: Text(selectLanguageTitle),
              //       children: [
              //         SimpleDialogOption(
              //           onPressed: () {
              //             Navigator.pop(context, const Locale('en'));
              //           },
              //           child: Text(englishText),
              //         ),
              //         SimpleDialogOption(
              //           onPressed: () {
              //             Navigator.pop(context, const Locale('es'));
              //           },
              //           child: Text(spanishText),
              //         ),
              //       ],
              //     );
              //   },
              // );
              // if (selectedLocale != null) {
              //   // localeProvider.setLocale(selectedLocale); // This will be uncommented later
              //    setState(() { // Temporary update for display until LocaleProvider is fully integrated
              //       if (selectedLocale.languageCode == 'es') _language = "Spanish";
              //       else _language = "English";
              //    });
              // }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language switching will be implemented soon!')),
              );
            },
            leading: const Icon(Icons.language),
          ),
          // About Section
          ListTile(
            title: Text(aboutText),
            trailing: const Icon(Icons.info_outline),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Triple M Garage App', // This could also be localized
                applicationVersion: '1.0.0',
                applicationIcon: Padding( // Use Padding for better spacing if needed
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('images/logo.jpg', height: 40),
                ),
                children: [
                  const Text('This app helps you manage and find parking easily.'),
                ],
              );
            },
          ),
          const Divider(),
          // Logout Option
          ListTile(
            title: Text(logoutText),
            trailing: const Icon(Icons.logout),
            leading: const Icon(Icons.exit_to_app, color: Colors.orangeAccent),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).clearUserData();
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          // Delete Account Option
          ListTile(
            title: Text(deleteAccountText),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    // ... (confirm delete dialog logic remains the same) ...
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) { // Changed context name to avoid conflict
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Pass the outer context to _deleteAccount
      await _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext outerContext) async { // Renamed context parameter
    // Show loading indicator using outerContext
    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in.");
      }
      final uid = user.uid;

      final WriteBatch batch = FirebaseFirestore.instance.batch();

      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in bookingsQuery.docs) {
        batch.delete(doc.reference);
      }

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.delete(userDocRef);

      await batch.commit();
      await user.delete();

      // Use outerContext for Provider
      Provider.of<UserProvider>(outerContext, listen: false).clearUserData();

      Navigator.of(outerContext).pop(); // Dismiss loading indicator

      Navigator.pushAndRemoveUntil(
        outerContext, // Use outerContext for navigation
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(outerContext).showSnackBar( // Use outerContext
        const SnackBar(content: Text('Account deleted successfully.')),
      );

    } on FirebaseAuthException catch (e) {
      Navigator.of(outerContext).pop();
      String message = e.message ?? 'Error deleting account.';
      if (e.code == 'requires-recent-login') {
        message = 'This operation is sensitive and requires recent authentication. Please log out and log back in before trying again.';
      }
      ScaffoldMessenger.of(outerContext).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      Navigator.of(outerContext).pop();
      ScaffoldMessenger.of(outerContext).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}

// Example UserProvider method (ensure this exists in your UserProvider)
// class UserProvider with ChangeNotifier {
//   String fullName = "";
//   // ... other properties
//   void clearUserData() {
//     fullName = "";
//     // Clear other user-specific data
//     notifyListeners();
//   }
// }
