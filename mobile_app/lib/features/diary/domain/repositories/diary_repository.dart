import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getMealsForDate(DateTime date);
  Future<DiaryEntry> insertMeal(DiaryEntry entry);
  Future<void> deleteMeal(int id, DateTime date);
  Future<Map<DateTime, double>> getCaloriesPerDay(int days);
}