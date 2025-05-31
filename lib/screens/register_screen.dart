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

  // Accepts 1-3 Arabic letters (optionally with spaces) followed by 1-4 Arabic-Indic digits.
  final RegExp _plateRegex = RegExp(
    r'^[\u0621-\u064A](?:\s?[\u0621-\u064A]){0,3}\s*[\u0660-\u0669]{1,4}$', // Changed {0,2} to {0,3}
    unicode: true, // Keep unicode mode enabled!
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
    setState(() {
      _plateControllers.add(TextEditingController());
    });
  }

  Future<void> _onRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final uid = userCredential.user!.uid;

        final plates = _plateControllers
            .map((c) => c.text.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'plateNumbers': plates,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setFullName(_fullNameController.text.trim());
        userProvider.setUsername(_emailController.text.trim());
        userProvider.setPhoneNumber(_phoneController.text.trim());
        // TODO: store plates in provider if needed

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration error')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset('images/logo.jpg', height: 120),
              ),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 15),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter your phone number' : null,
              ),
              const SizedBox(height: 15),

              // Dynamic Plate Fields
              ..._plateControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrl = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: ctrl,
                      inputFormatters: [ArabicNumbersInputFormatter()],
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: 'Plate Number ${idx + 1}',
                        hintText: 'مثال: أ ب ج ١٢٣٤',
                        hintTextDirection: TextDirection.rtl,
                      ),
                      validator: (v) {
                        print("Validating: '$v'");
                        final trimmedValue = v?.trim() ?? '';
                        print("Trimmed:   '$trimmedValue'");

                        // --- Please make sure this line is added and runs ---
                        print("Code Units: ${trimmedValue.codeUnits}");
                        // --------------------------------------------------

                        if (trimmedValue.isEmpty) return 'Enter plate number';

                        final bool isMatch = _plateRegex.hasMatch(trimmedValue);
                        print("Regex match: $isMatch");

                        if (!isMatch) return 'Invalid format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addPlateField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Plate'),
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a password';
                  if (v.length < 6) return 'Minimum 6 chars';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Confirm Password
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
                onPressed: _onRegister,
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
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
    );
  }
}
