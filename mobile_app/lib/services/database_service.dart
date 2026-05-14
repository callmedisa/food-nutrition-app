import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';

/// Cross-platform storage (works on web, iOS, Android, desktop).
/// Meals are stored per-day as JSON lists; profile as a single JSON object.
class DatabaseService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _sp async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static String _dayKey(DateTime d) =>
    'meals_${d.year}_${d.month.toString().padLeft(2, '0')}_${d.day.toString().padLeft(2, '0')}';

  // ── Meals ──────────────────────────────────────────────

  static Future<List<MealEntry>> getMealsForDate(DateTime date) async {
    final sp = await _sp;
    final raw = sp.getString(_dayKey(date));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((m) => MealEntry.fromMap(Map<String, dynamic>.from(m as Map))).toList();
  }

  static Future<MealEntry> insertMeal(MealEntry entry) async {
    final sp = await _sp;
    final key = _dayKey(entry.time);
    final existing = await getMealsForDate(entry.time);
    final id = DateTime.now().millisecondsSinceEpoch;
    final saved = MealEntry(dbId: id, food: entry.food, grams: entry.grams, time: entry.time);
    existing.add(saved);
    await sp.setString(key, jsonEncode(existing.map((e) => e.toMap()).toList()));
    return saved;
  }

  static Future<void> deleteMeal(int id, DateTime date) async {
    final sp = await _sp;
    final key = _dayKey(date);
    final existing = await getMealsForDate(date);
    existing.removeWhere((e) => e.dbId == id);
    await sp.setString(key, jsonEncode(existing.map((e) => e.toMap()).toList()));
  }

  /// Returns total calories per day for the last [days] days (including today).
  static Future<Map<DateTime, double>> getCaloriesPerDay(int days) async {
    final Map<DateTime, double> result = {};
    final now = DateTime.now();
    for (var i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1 - i));
      final meals = await getMealsForDate(day);
      result[day] = meals.fold(0.0, (s, m) => s + m.calories);
    }
    return result;
  }

  // ── Profile ────────────────────────────────────────────

  static Future<UserProfile?> getProfile() async {
    final sp = await _sp;
    final raw = sp.getString('user_profile');
    if (raw == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final sp = await _sp;
    await sp.setString('user_profile', jsonEncode(profile.toMap()));
  }
}
