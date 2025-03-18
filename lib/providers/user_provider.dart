// lib/providers/user_provider.dart

import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = "Homoss";
  String _userPassword = "123456";
  String _fullName = "John Doe";
  String _phoneNumber = "";
  String _address = "";

  String get username => _username;
  String get userPassword => _userPassword;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;

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
}
