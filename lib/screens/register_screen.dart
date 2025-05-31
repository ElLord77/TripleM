// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/providers/user_provider.dart';
import 'package:gdp_app/screens/dashboard_screen.dart';
import 'package:gdp_app/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';

/// Formatter to convert ASCII digits to Arabic-Indic digits as the user types.
class ArabicNumbersInputFormatter extends TextInputFormatter {
  static const Map<String, String> _arabicDigits = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
  };

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final converted = newValue.text.split('').map((char) {
      return _arabicDigits[char] ?? char;
    }).join();
    return newValue.copyWith(
      text: converted,
      selection: newValue.selection,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  List<TextEditingController> _plateControllers = [TextEditingController()];
  bool _isLoading = false; // To show loading indicator

  // Regex for:
  // - 1-4 Arabic letters, with a single space between each if more than one.
  // - Exactly ONE space as a separator.
  // - 1-4 Arabic-Indic digits, with a single space between each if more than one.
  final RegExp _plateRegex = RegExp(
    r'^[\u0621-\u064A](?:\s[\u0621-\u064A]){0,3}\s[\u0660-\u0669](?:\s[\u0660-\u0669]){0,3}$', // Changed \s{2} to \s
    unicode: true,
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var ctrl in _plateControllers) ctrl.dispose();
    super.dispose();
  }

  void _addPlateField() {
    if (_isLoading) return; // Prevent adding fields while loading
    setState(() {
      _plateControllers.add(TextEditingController());
    });
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Manually validate all plate fields
    bool allPlatesValid = true;
    for (var controller in _plateControllers) {
      final value = controller.text.trim();
      if (value.isNotEmpty && !_plateRegex.hasMatch(value)) {
        allPlatesValid = false;
        break;
      }
    }

    if (!allPlatesValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One or more plate numbers have an invalid format. Use: X X X Y Y Y Y')), // Updated hint
      );
      return;
    }

    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      final plates = _plateControllers
          .map((c) => c.text.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      // Check for plate uniqueness before creating the user
      if (plates.isNotEmpty) {
        final conflictQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('plateNumbers', arrayContainsAny: plates)
            .get();
        if (conflictQuery.docs.isNotEmpty) {
          // Extract which plates are conflicting to show a more specific message
          List<String> conflictingPlatesInDB = [];
          for(var doc in conflictQuery.docs){
            List<String> existingPlates = List<String>.from(doc.data()['plateNumbers'] ?? []);
            for(String newPlate in plates){
              if(existingPlates.contains(newPlate) && !conflictingPlatesInDB.contains(newPlate)){
                conflictingPlatesInDB.add(newPlate);
              }
            }
          }
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Plate(s) ${conflictingPlatesInDB.join(", ")} already registered.')),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
      }

      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'plateNumbers': plates,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setFullName(_fullNameController.text.trim());
      userProvider.setUsername(_emailController.text.trim()); // Assuming username is email
      userProvider.setPhoneNumber(_phoneController.text.trim());
      // TODO: store plates in provider if needed

      if (!mounted) return;
      Navigator.pushAndRemoveUntil( // Changed to pushAndRemoveUntil
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );

    } on FirebaseAuthException catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration error')),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
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
            const Text('Register'),
          ],
        ),
      ),
      body: Stack( // Added Stack for loading indicator
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Image.asset('images/logo.jpg', height: 120),
                  ),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Enter your phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("Car Plate Numbers:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._plateControllers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ctrl = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ctrl,
                              inputFormatters: [ArabicNumbersInputFormatter()],
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                labelText: 'Plate Number ${idx + 1}',
                                hintText: 'مثال: أ ب ج ١ ٢ ٣ ٤', // Updated hint
                                hintTextDirection: TextDirection.rtl,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final trimmedValue = v?.trim() ?? '';
                                if (idx == 0 && trimmedValue.isEmpty) return 'Enter at least one plate number'; // Optional: require at least one plate
                                if (trimmedValue.isNotEmpty && !_plateRegex.hasMatch(trimmedValue)) {
                                  return 'Invalid format. Use: X X X Y Y Y Y'; // Updated error message example
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_plateControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: _isLoading ? null : () {
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
                      onPressed: _isLoading ? null : _addPlateField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another Plate'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    onPressed: _isLoading ? null : _onRegister,
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    child: const Text('Already have an account? Sign In'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) // Loading indicator overlay
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
