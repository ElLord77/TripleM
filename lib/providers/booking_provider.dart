// lib/providers/booking_provider.dart

import 'package:flutter/material.dart';

/// The model for a booking, now with docId for Firestore deletion.
class Booking {
  final String docId;
  final String slotName;
  final String date;
  final String startTime;
  final String leavingTime;

  Booking({
    required this.docId,
    required this.slotName,
    required this.date,
    required this.startTime,
    required this.leavingTime,
  });
}

class BookingProvider with ChangeNotifier {
  Booking? _currentBooking;
  final List<Booking> _upcomingBookings = [];

  Booking? get currentBooking => _currentBooking;
  List<Booking> get upcomingBookings => _upcomingBookings;

  /// Add a new booking to the list and set it as current
  void addBooking(Booking booking) {
    _currentBooking = booking;
    _upcomingBookings.add(booking);
    notifyListeners();
  }

  /// Remove a specific booking
  void removeBooking(Booking booking) {
    if (_currentBooking != null && _currentBooking!.docId == booking.docId) {
      _currentBooking = null;
    }
    _upcomingBookings.removeWhere((b) => b.docId == booking.docId);
    notifyListeners();
  }

  /// Clear all bookings
  void clearBookings() {
    _currentBooking = null;
    _upcomingBookings.clear();
    notifyListeners();
  }
}
