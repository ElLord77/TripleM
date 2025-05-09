import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NonRegisteredUserScreen extends StatefulWidget {
  const NonRegisteredUserScreen({Key? key}) : super(key: key);

  @override
  _NonRegisteredUserScreenState createState() =>
      _NonRegisteredUserScreenState();
}

class _NonRegisteredUserScreenState extends State<NonRegisteredUserScreen> {
  String? plateNumber;
  double? fee;

  @override
  void initState() {
    super.initState();
    fetchParkingData();  // Fetch the parking data when the screen loads
  }

  // Fetch the parking data from Firestore
  Future<void> fetchParkingData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Get the most recent parking record
      QuerySnapshot querySnapshot = await firestore
          .collection('parking_records')  // Firestore collection
          .orderBy('entry_time', descending: true)  // Get the latest entry first
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var parkingData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          plateNumber = parkingData['plate_number'];
          fee = parkingData['fee'].toDouble();
        });
      }
    } catch (e) {
      print("Error fetching parking data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Non-Registered User Parking"),
      ),
      body: plateNumber == null || fee == null
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Parking Information",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text("Plate Number: $plateNumber"),
            const SizedBox(height: 8),
            Text("Fee: \$${fee?.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
