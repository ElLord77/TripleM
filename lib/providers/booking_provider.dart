// lib/providers/booking_provider.dart

import 'package:flutter/material.dart';

/// The model for a booking, now with startTime and leavingTime.
class Booking {
  final String slotName;
  final String date;
  final String startTime;    // Arrival
  final String leavingTime;  // Departure

  Booking({
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
    // If the booking is the same as _currentBooking, clear it
    if (_currentBooking != null &&
        _currentBooking!.slotName == booking.slotName &&
        _currentBooking!.date == booking.date &&
        _currentBooking!.startTime == booking.startTime &&
        _currentBooking!.leavingTime == booking.leavingTime) {
      _currentBooking = null;
    }

    _upcomingBookings.removeWhere((b) =>
    b.slotName == booking.slotName &&
        b.date == booking.date &&
        b.startTime == booking.startTime &&
        b.leavingTime == booking.leavingTime);

    notifyListeners();
  }

  /// Clear all bookings
  void clearBookings() {
    _currentBooking = null;
    _upcomingBookings.clear();
    notifyListeners();
  }
}
