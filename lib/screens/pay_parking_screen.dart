// lib/screens/pay_parking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// If ArabicNumbersInputFormatter is in a utils file, import it.
// Otherwise, define it here or copy from dashboard_screen.dart's previous version.

// ArabicNumbersInputFormatter (can be moved to a utils file)
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
    final converted = newValue.text
        .split('')
        .map((char) => _arabicDigits[char] ?? char)
        .join();
    return newValue.copyWith(text: converted, selection: newValue.selection);
  }
}

class PayParkingScreen extends StatefulWidget {
  const PayParkingScreen({Key? key}) : super(key: key);

  @override
  State<PayParkingScreen> createState() => _PayParkingScreenState();
}

class _PayParkingScreenState extends State<PayParkingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _parkingSessionData;

  Future<void> _fetchParkingDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _parkingSessionData = null; // Clear previous data
    });

    String plateNumber = _plateNumberController.text.trim();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('activeParkingSessions') // MAKE SURE THIS COLLECTION NAME IS CORRECT
          .where('plateNumber', isEqualTo: plateNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _parkingSessionData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No active parking session found for plate: $plateNumber')),
          );
        }
      }
    } catch (e) {
      print('Error fetching parking details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding session: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPaymentScreen() {
    if (_parkingSessionData == null) return;
    // TODO: Navigate to your actual payment screen, passing necessary data
    // For example:
    // Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //   YourPaymentScreen(sessionData: _parkingSessionData!)
    // ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment screen navigation not implemented yet.')),
    );
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay for Parking'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Enter your car plate number to find your parking session:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _plateNumberController,
                    textDirection: TextDirection.rtl,
                    inputFormatters: [ArabicNumbersInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Plate Number',
                      hintText: 'مثال: أ ب ج ١٢٣٤',
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Plate number is required';
                      }
                      // Add your specific plate format regex validation here if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Find Session'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _fetchParkingDetails,
                  ),
                  const SizedBox(height: 30),
                  if (_parkingSessionData != null)
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parking Session Details:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text('Plate Number: ${_parkingSessionData!['plateNumber'] ?? 'N/A'}'),
                            Text('Entry Time: ${(_parkingSessionData!['entryTime'] as Timestamp?)?.toDate().toLocal().toString().substring(0,16) ?? 'N/A'}'),
                            const SizedBox(height: 8),
                            Text(
                              'Amount Due: \$${(_parkingSessionData!['amountDue'] ?? 0.0).toDouble().toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: _navigateToPaymentScreen,
                                child: const Text('Confirm and Proceed to Payment'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
