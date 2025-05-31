// lib/providers/user_provider.dart

import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = "";
  String _userPassword = "123456";  // initial default password (can be "")
  String _fullName = "";
  String _phoneNumber = "";
  String _address = "";
  String _plateNumber = "";


  String get username => _username;
  String get userPassword => _userPassword;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  String get plateNumber => _plateNumber;


  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setUserPassword(String password) {
    _userPassword = password;
    notifyListeners();
  }

  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setAddress(String addr) {
    _address = addr;
    notifyListeners();
  }

  void setPlateNumber(String plate) {
    _plateNumber = plate;
    notifyListeners();
  }

  /// Clears all user-related fields (useful on logout)
  void clearUserData() {
    _username = "";
    _userPassword = "";
    _fullName = "";
    _phoneNumber = "";
    _address = "";
    _plateNumber = "";
    notifyListeners();
  }
}
