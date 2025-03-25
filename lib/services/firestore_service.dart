// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdp_app/providers/booking_provider.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Overlap function for two date ranges
  bool _timesOverlap(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  /// Attempt to reserve a slot, checking partial overlaps with full DateTimes.
  /// Returns the newly created doc ID if successful.
  Future<String> reserveSlotDateTime({
    required String slotName,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String userEmail,
  }) async {
    // 1) Query all existing bookings for this slot
    final snapshot = await _db
        .collection('bookings')
        .where('slotName', isEqualTo: slotName)
        .get();

    // 2) Check each booking for overlap using Timestamps
    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['startDateTime'] == null || data['endDateTime'] == null) {
        continue;
      }

      final existingStart = (data['startDateTime'] as Timestamp).toDate();
      final existingEnd   = (data['endDateTime']   as Timestamp).toDate();

      if (_timesOverlap(existingStart, existingEnd, startDateTime, endDateTime)) {
        throw Exception(
          "This slot is partially booked from ${existingStart.toLocal()} to ${existingEnd.toLocal()}",
        );
      }
    }

    // 3) If no overlap, create a new doc
    final docRef = await _db.collection('bookings').add({
      'slotName':      slotName,
      'startDateTime': startDateTime,  // Will store as a Firestore Timestamp
      'endDateTime':   endDateTime,
      'userId':        userEmail,
      'reservedAt':    FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Fetch all bookings for a specific user by email, returning Booking objects
  Future<List<Booking>> getBookings({required String userEmail}) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userEmail)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      // Safely parse Timestamps
      final startTS = data['startDateTime'] as Timestamp?;
      final endTS   = data['endDateTime']   as Timestamp?;

      final startDT = startTS != null ? startTS.toDate() : DateTime.now();
      final endDT   = endTS != null   ? endTS.toDate()   : DateTime.now();

      return Booking(
        docId:    doc.id,
        slotName: data['slotName'] ?? '',
        startDateTime: startDT,
        endDateTime:   endDT,
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
