// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// Formatter to convert ASCII digits to Arabic-Indic digits as the user types.
class ArabicNumbersInputFormatter extends TextInputFormatter {
  static const Map<String, String> _arabicDigits = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
  };

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final converted = newValue.text
        .split('')
        .map((char) => _arabicDigits[char] ?? char)
        .join();
    return newValue.copyWith(text: converted, selection: newValue.selection);
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>(); // Key for the change password form

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<TextEditingController> _plateControllers = [];

  // Controllers for password change
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _loading = true;
  bool _isChangingPassword = false; // For password change loading state

  final RegExp _plateRegex = RegExp(
    r'^[\u0621-\u064A](?:\s[\u0621-\u064A]){0,3}\s{2}[\u0660-\u0669](?:\s[\u0660-\u0669]){0,3}$',
    unicode: true,
  );

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // ... (existing _loadProfileData method remains the same) ...
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final uid = currentUser.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _fullNameController.text = data['fullName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _addressController.text = data['address'] ?? '';
        final plates = data['plateNumbers'];
        if (plates is List) {
          _plateControllers = plates
              .map((p) => TextEditingController(text: p.toString()))
              .toList();
        }
      }
      _emailController.text = currentUser.email ?? _emailController.text;
    } catch (e) {
      print("Error loading profile data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data: ${e.toString()}')),
        );
      }
    } finally {
      if (_plateControllers.isEmpty) {
        _plateControllers.add(TextEditingController());
      }
      if(mounted){
        setState(() => _loading = false);
      }
    }
  }

  void _addPlateField() {
    setState(() {
      _plateControllers.add(TextEditingController());
    });
  }

  Future<void> _saveProfile() async {
    // ... (existing _saveProfile method remains largely the same) ...
    // Ensure you use _profileFormKey for this part
    if (!_profileFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct errors in your profile information.')),
      );
      return;
    }

    bool allPlatesValid = true;
    for (var controller in _plateControllers) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        // Debug prints can be removed
        // print("--- Validating in _saveProfile ---");
        // print("Original Controller Text: '${controller.text}'");
        // print("Trimmed Value for Regex: '$value'");
        // print("Code Units for Regex: ${value.codeUnits}");
        final bool isMatch = _plateRegex.hasMatch(value);
        // print("Regex Match: $isMatch with Pattern: ${_plateRegex.pattern}");
        // print("---------------------------------");

        if (!isMatch) {
          allPlatesValid = false;
          // print("Invalid plate found in _saveProfile (confirmed by detailed check): $value");
          break;
        }
      }
    }

    if (!allPlatesValid) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('One or more plate numbers have an invalid format. Use: X X X  Y Y Y Y')),
        );
      }
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if(mounted) setState(() => _loading = true);

    final uid = currentUser.uid;
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final plates = _plateControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    // Plate uniqueness check... (existing logic)
    if (plates.isNotEmpty) {
      try {
        final conflictQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('plateNumbers', arrayContainsAny: plates)
            .get();

        for (var doc in conflictQuery.docs) {
          if (doc.id != uid) {
            final existingPlates = List<String>.from(doc.data()['plateNumbers'] ?? []);
            final conflictPlates = plates.where((p) => existingPlates.contains(p)).toList();
            if (conflictPlates.isNotEmpty) {
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Plate(s) ${conflictPlates.join(', ')} already in use by another user.')),
                );
                setState(() => _loading = false);
              }
              return;
            }
          }
        }
      } catch (e) {
        print("Error checking plate uniqueness: $e");
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking plate uniqueness: ${e.toString()}')),
          );
          setState(() => _loading = false);
        }
        return;
      }
    }
    // Save to Firestore... (existing logic)
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': _emailController.text.trim(),
        'phoneNumber': phone,
        'address': address,
        'plateNumbers': plates,
      }, SetOptions(merge: true));

      final userProv = Provider.of<UserProvider>(context, listen: false);
      userProv.setFullName(fullName);
      userProv.setPhoneNumber(phone);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    } finally {
      if(mounted){
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() { _isChangingPassword = true; });

    final user = FirebaseAuth.instance.currentUser;
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found or email is missing.')),
      );
      setState(() { _isChangingPassword = false; });
      return;
    }

    try {
      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // If re-authentication is successful, update the password
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "Failed to change password.";
        if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect current password.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The new password is too weak.';
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isChangingPassword = false; });
      }
    }
  }


  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    for (var c in _plateControllers) c.dispose();
    // Dispose new password controllers
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('images/logo.jpg', height: 30),
            const SizedBox(width: 8),
            const Text('Profile'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (existing My Car Plates section) ...
            Text(
              'My Car Plates',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Column(
              children: _plateControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl,
                          inputFormatters: [ArabicNumbersInputFormatter()],
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            labelText: 'Plate ${idx + 1}',
                            hintText: 'مثال: أ ب ج  ١ ٢ ٣ ٤',
                            hintTextDirection: TextDirection.rtl,
                          ),
                          validator: (v) {
                            final trimmedValueOriginalValidator = v?.trim() ?? '';
                            if (trimmedValueOriginalValidator.isNotEmpty) {
                              final bool isMatchOriginalValidator = _plateRegex.hasMatch(trimmedValueOriginalValidator);
                              if (!isMatchOriginalValidator) {
                                return 'Invalid format. Use: X X X  Y Y Y Y';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _plateControllers.removeAt(idx).dispose();
                            if (_plateControllers.isEmpty) {
                              _plateControllers.add(TextEditingController());
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addPlateField,
                icon: const Icon(Icons.add),
                label: const Text('Add Plate'),
              ),
            ),
            Divider(color: theme.dividerColor, height: 40),

            Text(
              'Edit Profile Information',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Form(
              key: _profileFormKey, // Use _profileFormKey here
              child: Column(
                children: [
                  // ... (existing Full Name, Email, Phone, Address TextFormFields) ...
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                    ),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      child: _loading && !_isChangingPassword // Show loader only if saving profile, not changing password
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))
                          : const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, height: 40),

            // --- Change Password Section ---
            Text(
              'Change Password',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Form(
              key: _passwordFormKey, // Use the new key for this form
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(labelText: 'Current Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isChangingPassword ? null : _changePassword,
                      child: _isChangingPassword
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))
                          : const Text('Change Password'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}
