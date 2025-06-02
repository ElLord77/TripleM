// lib/screens/app_dropdown1.dart

import 'package:flutter/material.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:gdp_app/screens/register_screen.dart';
import 'package:gdp_app/screens/contact_us_screen.dart';
// You might need to import your DashboardScreen if you add a link to it from the drawer
// import 'package:gdp_app/screens/dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  // Added key for good practice, though not strictly necessary for StatelessWidget if not subclassed.
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get the current theme
    final TextTheme textTheme = theme.textTheme; // For easier access to text styles
    final Color? drawerHeaderColor = theme.drawerTheme.backgroundColor ?? theme.primaryColorDark; // Fallback
    final TextStyle? headerTextStyle = textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary);
    final TextStyle? listTileTextStyle = textTheme.bodyLarge; // Or choose another appropriate style

    return Drawer(
      // The Drawer's background color will be determined by theme.drawerTheme.backgroundColor
      // or theme.canvasColor by default.
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // Use color from DrawerThemeData or a fallback from the theme
              color: drawerHeaderColor,
            ),
            child: Text(
              'Triple M Garage',
              // Use a text style that adapts to the header's background color
              style: headerTextStyle,
            ),
          ),
          ListTile(
            leading: Icon(Icons.login, color: theme.listTileTheme.iconColor), // Use themed icon color
            title: Text(
              'Sign in',
              style: listTileTextStyle, // Use themed text style
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.app_registration, color: theme.listTileTheme.iconColor),
            title: Text(
              'Registration',
              style: listTileTextStyle,
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail, color: theme.listTileTheme.iconColor),
            title: Text(
              'Contact us',
              style: listTileTextStyle,
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactScreen()),
              );
            },
          ),
          // Example: Add a link back to Dashboard if this drawer is used from other screens
          // const Divider(),
          // ListTile(
          //   leading: Icon(Icons.dashboard, color: theme.listTileTheme.iconColor),
          //   title: Text(
          //     'Dashboard',
          //     style: listTileTextStyle,
          //   ),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     // Navigate to Dashboard, ensuring it's the root or handled appropriately
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(builder: (context) => const DashboardScreen()),
          //       (Route<dynamic> route) => false, // Or a more specific predicate
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
