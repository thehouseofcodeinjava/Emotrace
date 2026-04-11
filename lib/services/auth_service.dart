// TODO: auth service | Author: Rajat Mahajan
// Service: AuthService — local authentication (JWT), for Month 2 full implementation

import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  // TODO: Implement full auth in Month 2 — currently stub for architecture
  Future<User?> login(String email, String password) async {
    // TODO: hash password, verify against stored hash, create session token
    throw UnimplementedError('Auth will be implemented in Month 2');
  }

  Future<void> logout(String userId) async {
    // TODO: invalidate session token
    await _db.delete('sessions', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<User?> getCurrentUser() async {
    // TODO: read JWT from secure storage, validate, return user
    return null;
  }

  Future<bool> isLoggedIn() async {
    // TODO: check for valid session token in secure storage
    return false;
  }
}
