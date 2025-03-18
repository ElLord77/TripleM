// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    required String userId,
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
            "This slot is partially booked from "
                "${data['startTime']} to ${data['leavingTime']}",
          );
        }
      }
    }

    // 3) If no overlap, create a new doc with auto-ID
    final docRef = await _db.collection('bookings').add({
      'slotName': slotName,
      'date': date,
      'startTime': startTime,
      'leavingTime': leavingTime,
      'userId': userId,
      'reservedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
