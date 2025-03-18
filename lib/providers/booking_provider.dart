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

  void clearBookings() {
    _currentBooking = null;
    _upcomingBookings.clear();
    notifyListeners();
  }
}
