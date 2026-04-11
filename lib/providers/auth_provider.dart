// TODO: auth provider | Author: Rajat Mahajan
// Provider: AuthProvider — authentication state (stub for Month 2)

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // TODO: implement login in Month 2
  Future<void> login(String email, String password) async {
    // TODO: call AuthService.login(), update _user
    notifyListeners();
  }

  // TODO: implement logout in Month 2
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
