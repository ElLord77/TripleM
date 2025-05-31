// lib/screens/pay_parking_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:gdp_app/screens/payment_screen.dart';

class PayParkingScreen extends StatefulWidget {
  const PayParkingScreen({Key? key}) : super(key: key);

  @override
  State<PayParkingScreen> createState() => _PayParkingScreenState();
}

class _PayParkingScreenState extends State<PayParkingScreen> {
  bool _isLoading = true;
  List<String> _userPlates = [];
  String? _selectedPlate;
  Map<String, dynamic>? _parkingSessionData;
  String? _parkingSessionDocId; // To store the document ID
  bool _isFetchingRecord = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPlates();
  }

  Future<void> _fetchUserPlates() async {
    // ... (this method remains the same as before) ...
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _userPlates = [];
      _selectedPlate = null;
      _parkingSessionData = null;
      _parkingSessionDocId = null; // Reset doc ID
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to view your plates.')),
        );
        setState(() { _isLoading = false; });
      }
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        final platesFromDb = data['plateNumbers'];
        if (platesFromDb is List && platesFromDb.isNotEmpty) {
          if (mounted) {
            setState(() {
              _userPlates = List<String>.from(platesFromDb.map((e) => e.toString()));
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No registered car plates found for your account.')),
            );
          }
        }
      }
    } catch (e) {
      print('Error fetching user plates: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching your car plates: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _fetchParkingDetailsForSelectedPlate() async {
    if (_selectedPlate == null || _selectedPlate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a car plate.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isFetchingRecord = true;
      _parkingSessionData = null;
      _parkingSessionDocId = null; // Reset doc ID
    });

    String plateToFetch = _selectedPlate!;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('parking_records')
          .where('plate_number', isEqualTo: plateToFetch)
          .orderBy('entry_time', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        if (mounted) {
          setState(() {
            _parkingSessionData = doc.data() as Map<String, dynamic>;
            _parkingSessionDocId = doc.id; // Store the document ID
            print("PayParkingScreen: Fetched _parkingSessionData: $_parkingSessionData with ID: $_parkingSessionDocId");
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No parking record found for plate: $plateToFetch that requires payment.')),
          );
        }
      }
    } catch (e) {
      print('Error fetching parking details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding record: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingRecord = false;
        });
      }
    }
  }

  void _navigateToPaymentScreen() {
    if (_parkingSessionData == null || _parkingSessionDocId == null) { // Check for doc ID too
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No parking session data or ID to proceed.')),
      );
      return;
    }

    final String plateNumber = _parkingSessionData!['plate_number'] as String? ?? 'N/A';
    final Timestamp? entryTimestamp = _parkingSessionData!['entry_time'] as Timestamp?;
    final Timestamp? exitTimestamp = _parkingSessionData!['exit_time'] as Timestamp?;

    final dynamic rawFee = _parkingSessionData!['fee'];
    print("PayParkingScreen: Raw fee from Firestore: $rawFee (Type: ${rawFee.runtimeType})");
    final double feeFromDb = (rawFee ?? 0.0).toDouble();
    print("PayParkingScreen: feeFromDb being passed to PaymentScreen: $feeFromDb");

    if (entryTimestamp == null || exitTimestamp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing entry or exit time for the parking session.')),
      );
      return;
    }

    final DateTime entryDateTime = entryTimestamp.toDate();
    final DateTime exitDateTime = exitTimestamp.toDate();

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormat = DateFormat('h:mm a');

    final String startDate = dateFormat.format(entryDateTime);
    final String startTime = timeFormat.format(entryDateTime);
    final String endDate = dateFormat.format(exitDateTime);
    final String endTime = timeFormat.format(exitDateTime);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          slotName: plateNumber,
          startDate: startDate,
          startTime: startTime,
          endDate: endDate,
          endTime: endTime,
          fee: feeFromDb,
          documentId: _parkingSessionDocId!, // Pass the document ID
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method remains largely the same, ensure it uses the state variables correctly) ...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay for Parking'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(semanticsLabel: "Loading your plates..."))
                : _userPlates.isEmpty
                ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No car plates registered to your account.', textAlign: TextAlign.center),
                    const SizedBox(height:10),
                    ElevatedButton(onPressed: (){ Navigator.pop(context);}, child: const Text("Go Back"))
                  ],
                )
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Select your car plate to find your parking record:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPlate,
                  hint: const Text('Select Plate'),
                  isExpanded: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0)
                  ),
                  items: _userPlates.map((String plate) {
                    return DropdownMenuItem<String>(
                      value: plate,
                      child: Text(plate), // Removed textDirection: TextDirection.rtl
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPlate = newValue;
                      _parkingSessionData = null;
                      _parkingSessionDocId = null; // Reset doc ID when plate changes
                    });
                  },
                  validator: (value) => value == null ? 'Please select a plate' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Find Record'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (_selectedPlate == null || _isFetchingRecord) ? null : _fetchParkingDetailsForSelectedPlate,
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
                            'Parking Record Details:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text('Plate Number: ${_parkingSessionData!['plate_number'] ?? 'N/A'}'),
                          Text('Entry Time: ${(_parkingSessionData!['entry_time'] as Timestamp?)?.toDate().toLocal().toString().substring(0,16) ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text(
                            'Fee: \$${(_parkingSessionData!['fee'] ?? 0.0).toDouble().toStringAsFixed(2)}',
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
          if (_isLoading || _isFetchingRecord)
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
