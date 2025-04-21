// lib/screens/non_registered_user_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NonRegisteredUserScreen extends StatefulWidget {
  const NonRegisteredUserScreen({Key? key}) : super(key: key);

  @override
  _NonRegisteredUserScreenState createState() =>
      _NonRegisteredUserScreenState();
}

class _NonRegisteredUserScreenState extends State<NonRegisteredUserScreen> {
  String? imageUrl;
  String? plateNumber;
  String? status;
  String? parkingDuration;
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
          status = parkingData['status'];
          String imagePath = parkingData['imagePath'] ?? ''; // Adjust field name if exists

          // Fetch the image URL from Firebase Storage
          FirebaseStorage storage = FirebaseStorage.instance;
          storage.ref().child(imagePath).getDownloadURL().then((url) {
            setState(() {
              imageUrl = url;
            });
          });

          // Calculate parking duration
          DateTime entryTime = (parkingData['entry_time'] as Timestamp).toDate();
          DateTime exitTime = (parkingData['exit_time'] as Timestamp).toDate();
          Duration duration = exitTime.difference(entryTime);
          parkingDuration = formatDuration(duration);
        });
      }
    } catch (e) {
      print("Error fetching parking data: $e");
    }
  }

  // Format parking duration into hours and minutes
  String formatDuration(Duration duration) {
    return '${duration.inHours} hours and ${duration.inMinutes % 60} minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Non-Registered User Parking"),
      ),
      body: imageUrl == null
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
            Text("Parking Duration: $parkingDuration"),
            const SizedBox(height: 8),
            Text("Fee: \$${fee?.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            Text("Status: $status"),
            const SizedBox(height: 16),
            Center(
              child: imageUrl == null
                  ? const CircularProgressIndicator()
                  : Image.network(imageUrl!),
            ),
          ],
        ),
      ),
    );
  }
}
