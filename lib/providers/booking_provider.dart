import 'package:flutter/material.dart';

/// The model for a booking, now with full DateTimes for multi-day usage.
class Booking {
  final String docId;
  final String slotName;
  final DateTime startDateTime;
  final DateTime endDateTime;

  Booking({
    required this.docId,
    required this.slotName,
    required this.startDateTime,
    required this.endDateTime,
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

  /// Replace all bookings at once (useful after signing in a new user).
  ///
  /// This method clears any old bookings, then calls `addBooking` on each
  /// new booking. Whichever booking is last in the list will become _currentBooking.
  /// If you want a different logic (e.g. earliest booking as current), you can
  /// adjust how they're sorted or added.
  void setAllBookings(List<Booking> newBookings) {
    // 1) Clear old data
    clearBookings();

    // 2) Optionally sort them if you want earliest or latest as current
    // newBookings.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    // 3) Add them so the last added becomes _currentBooking
    for (var booking in newBookings) {
      addBooking(booking);
    }
    // notifyListeners() is already called in addBooking, but you can call again if needed
    // notifyListeners();
  }
}
