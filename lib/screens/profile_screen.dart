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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Load profile data and plates from Firestore into controllers
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
    } catch (e) {
      // Handle errors if needed
    } finally {
      if (_plateControllers.isEmpty) {
        _plateControllers.add(TextEditingController());
      }
      setState(() => _loading = false);
    }
  }

  void _addPlateField() {
    setState(() {
      _plateControllers.add(TextEditingController());
    });
  }

  /// Save updated profile and plates, enforcing unique plates across users
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final uid = currentUser.uid;
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final plates = _plateControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    // Check uniqueness in Firestore
    if (plates.isNotEmpty) {
      final conflictQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('plateNumbers', arrayContainsAny: plates)
          .get();
      // Exclude current user
      for (var doc in conflictQuery.docs) {
        if (doc.id != uid) {
          final conflictPlates = (doc.data()['plateNumbers'] as List)
              .map((e) => e.toString())
              .toSet()
              .intersection(plates.toSet());
          if (conflictPlates.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Plate(s) ${conflictPlates.join(', ')} already in use')),
            );
            return;
          }
        }
      }
    }

    // All clear: write to Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullName,
        'phoneNumber': phone,
        'address': address,
        'plateNumbers': plates,
      }, SetOptions(merge: true));

      // Update provider
      final userProv = Provider.of<UserProvider>(context, listen: false);
      userProv.setFullName(fullName);
      userProv.setPhoneNumber(phone);
      userProv.setAddress(address);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: \$e')),
      );
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
            // Plate section
            const Text(
              'My Car Plates',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._plateControllers.asMap().entries.map((entry) {
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
                          hintText: 'مثال: أ ب ج ١٢٣٤',
                          hintTextDirection: TextDirection.rtl,
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter plate number'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_plateControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _plateControllers.removeAt(idx).dispose();
                          });
                        },
                      ),
                  ],
                ),
              );
            }).toList(),
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
            // Profile section
            const Text(
              'Edit Profile',
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
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFFE94560)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Color(0xFFE94560)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                      ),
                      child: const Text(
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