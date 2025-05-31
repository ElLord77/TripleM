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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<TextEditingController> _plateControllers = [];
  bool _loading = true;

  // Updated Regex:
  // - 1-4 Arabic letters, with a single space between each if more than one.
  // - Exactly TWO spaces as a separator.
  // - 1-4 Arabic-Indic digits, with a single space between each if more than one.
  final RegExp _plateRegex = RegExp(
    r'^[\u0621-\u064A](?:\s[\u0621-\u064A]){0,3}\s[\u0660-\u0669](?:\s[\u0660-\u0669]){0,3}$', // Changed \s{2} to \s
    unicode: true,
  );


  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _loading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: ${e.toString()}')),
      );
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct errors in your profile information.')),
      );
      return;
    }

    bool allPlatesValid = true;
    for (var controller in _plateControllers) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        // Debug prints (can be removed after confirming fix)
        print("--- Validating in _saveProfile ---");
        print("Original Controller Text: '${controller.text}'");
        print("Trimmed Value for Regex: '$value'");
        print("Code Units for Regex: ${value.codeUnits}");
        final bool isMatch = _plateRegex.hasMatch(value);
        print("Regex Match: $isMatch with Pattern: ${_plateRegex.pattern}");
        print("---------------------------------");

        if (!isMatch) {
          allPlatesValid = false;
          print("Invalid plate found in _saveProfile (confirmed by detailed check): $value");
          break;
        }
      }
    }

    if (!allPlatesValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or more plate numbers have an invalid format. Use: X X X  Y Y Y Y')), // Updated example
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _loading = true);

    final uid = currentUser.uid;
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final plates = _plateControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    for (var c in _plateControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFF16213E),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Car Plates',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'مثال: أ ب ج  ١ ٢ ٣ ٤', // Updated hint for two spaces
                            hintStyle: const TextStyle(color: Colors.white54),
                            hintTextDirection: TextDirection.rtl,
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE94560)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) {
                            final trimmedValueOriginalValidator = v?.trim() ?? '';
                            if (trimmedValueOriginalValidator.isNotEmpty) {
                              final bool isMatchOriginalValidator = _plateRegex.hasMatch(trimmedValueOriginalValidator);
                              if (!isMatchOriginalValidator) {
                                return 'Invalid format. Use: X X X  Y Y Y Y'; // Updated error message
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
                icon: const Icon(Icons.add, color: Colors.white),
                label:
                const Text('Add Plate', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Divider(color: Colors.white38, height: 40),
            const Text(
              'Edit Profile Information',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFFE94560)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white70),
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFFE94560)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFFE94560)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter your address' : null,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 16)
                      ),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))
                          : const Text(
                        'Save Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
