// Service: SettingsService | Author: Piyush Puri | Date: 13 Apr 2026
// Single responsibility: read/write the settings table via DatabaseService.
// Follows the same pattern as MoodService.

import '../models/settings_model.dart';
import 'database_service.dart';

class SettingsService {
  final DatabaseService _db = DatabaseService();

  /// Returns null on first launch (no row in DB yet).
  Future<Settings?> loadSettings(String userId) async {
    final rows = await _db.query(
      'settings',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Settings.fromMap(rows.first);
  }

  /// Upsert — DatabaseService.insert uses ConflictAlgorithm.replace.
  Future<void> saveSettings(Settings settings) async {
    await _db.insert('settings', settings.toMap());
  }
}
