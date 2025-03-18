// lib/providers/user_provider.dart

import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = "User";
  String _userPassword = "123456";
  String _fullName = "John Doe";
  // Additional fields if needed (phoneNumber, address, profileImage, etc.)

  String get username => _username;
  String get userPassword => _userPassword;
  String get fullName => _fullName;
  // More getters for phone, address, etc.

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

// More setters for phone, address, etc.
}
