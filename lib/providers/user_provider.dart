// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = "User";
  String _userPassword = "";

  String get username => _username;
  String get userPassword => _userPassword;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setUserPassword(String password) {
    _userPassword = password;
    notifyListeners();
  }
}
