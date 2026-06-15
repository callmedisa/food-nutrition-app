import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_helper.dart';
import '../../domain/entities/user_profile.dart';

class ProfileLocalDataSource {
  Future<UserProfile?> getProfile() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'profile',
      {'id': 1, ...profile.toMap()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}