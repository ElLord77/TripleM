// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gdp_app/providers/booking_provider.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper to parse times (assuming "h:mm a" format, e.g. "8:00 PM")
  DateTime? _parseTime(String timeString) {
    try {
      final format = DateFormat("h:mm a");
      return format.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  bool _timesOverlap(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  /// Attempt to reserve a slot, checking partial overlaps.
  /// Returns the newly created doc ID if successful.
  Future<String> reserveSlot({
    required String slotName,
    required String date,
    required String startTime,
    required String leavingTime,
    required String userEmail, // now using email
  }) async {
    final newStart = _parseTime(startTime);
    final newEnd = _parseTime(leavingTime);

    if (newStart == null || newEnd == null) {
      throw Exception("Could not parse start or leaving time");
    }

    // 1) Query all existing bookings for this slot & date
    final snapshot = await _db
        .collection('bookings')
        .where('slotName', isEqualTo: slotName)
        .where('date', isEqualTo: date)
        .get();

    // 2) Check each booking for overlap
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final existingStart = _parseTime(data['startTime']);
      final existingEnd = _parseTime(data['leavingTime']);

      if (existingStart != null && existingEnd != null) {
        if (_timesOverlap(existingStart, existingEnd, newStart, newEnd)) {
          throw Exception(
            "This slot is partially booked from ${data['startTime']} to ${data['leavingTime']}",
          );
        }
      }
    }

    // 3) If no overlap, create a new doc with auto-ID and store the email
    final docRef = await _db.collection('bookings').add({
      'slotName': slotName,
      'date': date,
      'startTime': startTime,
      'leavingTime': leavingTime,
      'userId': userEmail, // store email here
      'reservedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Fetch all bookings for a specific user by email.
  Future<List<Booking>> getBookings({required String userEmail}) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userEmail)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Booking(
        docId: doc.id,
        slotName: data['slotName'] ?? '',
        date: data['date'] ?? '',
        startTime: data['startTime'] ?? '',
        leavingTime: data['leavingTime'] ?? '',
      );
    }).toList();
  }

  /// Create or update a user profile keyed by their email
  Future<void> updateUserProfileByEmail({
    required String email,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    // Use set(..., SetOptions(merge: true)) so it won't overwrite the entire doc if it exists
    await _db.collection('users').doc(email).set({
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    }, SetOptions(merge: true));
  }

  /// Fetch a user profile by email
  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    final docSnap = await _db.collection('users').doc(email).get();
    return docSnap.data();
  }
}
