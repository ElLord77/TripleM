// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Attempt to reserve a slot with a doc ID combining slot, date, and startTime.
  /// If the doc already exists, throw an exception => "Slot already booked!"
  Future<void> reserveSlot({
    required String slotName,
    required String date,
    required String startTime,
    required String leavingTime,
    required String userId,
  }) async {
    // e.g. "A1_2023-09-20_10:00 AM"
    final docId = '${slotName}_${date}_$startTime';
    final docRef = _db.collection('bookings').doc(docId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        // Already booked
        throw Exception("Slot already booked!");
      } else {
        // Create the doc
        transaction.set(docRef, {
          'slotName': slotName,
          'date': date,
          'startTime': startTime,
          'leavingTime': leavingTime,
          'userId': userId,
          'reservedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
