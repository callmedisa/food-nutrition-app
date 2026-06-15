import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_datasource.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource _dataSource;
  DiaryRepositoryImpl(this._dataSource);

  @override
  Future<List<DiaryEntry>> getMealsForDate(DateTime date) => _dataSource.getMealsForDate(date);

  @override
  Future<DiaryEntry> insertMeal(DiaryEntry entry) => _dataSource.insertMeal(entry);

  @override
  Future<void> deleteMeal(int id, DateTime date) => _dataSource.deleteMeal(id, date);

  @override
  Future<Map<DateTime, double>> getCaloriesPerDay(int days) => _dataSource.getCaloriesPerDay(days);
}