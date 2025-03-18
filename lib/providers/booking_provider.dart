// lib/providers/booking_provider.dart

import 'package:flutter/material.dart';

class Booking {
  final String slotName;
  final String date;
  final String time;

  Booking({
    required this.slotName,
    required this.date,
    required this.time,
  });
}

class BookingProvider with ChangeNotifier {
  Booking? _currentBooking;
  final List<Booking> _upcomingBookings = [];

  Booking? get currentBooking => _currentBooking;
  List<Booking> get upcomingBookings => _upcomingBookings;

  void addBooking(Booking booking) {
    _currentBooking = booking;
    _upcomingBookings.add(booking);
    notifyListeners();
  }

  /// Removes a single booking from the upcoming list.
  /// If it matches the current booking, also clears _currentBooking.
  void removeBooking(Booking booking) {
    // If the booking to remove is the same as _currentBooking, set it to null.
    if (_currentBooking != null &&
        _currentBooking!.slotName == booking.slotName &&
        _currentBooking!.date == booking.date &&
        _currentBooking!.time == booking.time) {
      _currentBooking = null;
    }

    _upcomingBookings.removeWhere((b) =>
    b.slotName == booking.slotName &&
        b.date == booking.date &&
        b.time == booking.time);

    notifyListeners();
  }

  void clearBookings() {
    _currentBooking = null;
    _upcomingBookings.clear();
    notifyListeners();
  }
}
