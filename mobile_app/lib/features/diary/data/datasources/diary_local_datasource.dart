import '../../../../core/db/database_helper.dart';
import '../../domain/entities/diary_entry.dart';

class DiaryLocalDataSource {
  Future<List<DiaryEntry>> getMealsForDate(DateTime date) async {
    final db = await DatabaseHelper.database;
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end   = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    final rows = await db.query(
      'meals',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'timestamp ASC',
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  Future<DiaryEntry> insertMeal(DiaryEntry entry) async {
    final db = await DatabaseHelper.database;
    final map = entry.toMap();
    map.remove('id');
    final id = await db.insert('meals', map);
    return DiaryEntry(id: id, food: entry.food, grams: entry.grams, time: entry.time);
  }

  Future<void> deleteMeal(int id, DateTime date) async {
    final db = await DatabaseHelper.database;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<DateTime, double>> getCaloriesPerDay(int days) async {
    final db = await DatabaseHelper.database;
    final result = <DateTime, double>{};
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final day = now.subtract(Duration(days: i));
      final d = DateTime(day.year, day.month, day.day);
      final start = d.millisecondsSinceEpoch;
      final end   = DateTime(d.year, d.month, d.day, 23, 59, 59).millisecondsSinceEpoch;
      final rows = await db.query(
        'meals',
        columns: ['food_calories', 'grams'],
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [start, end],
      );
      final total = rows.fold<double>(0, (s, r) {
        final cal  = (r['food_calories'] as num).toDouble();
        final gram = (r['grams'] as num).toDouble();
        return s + cal * gram / 100;
      });
      result[d] = total;
    }
    return result;
  }
}