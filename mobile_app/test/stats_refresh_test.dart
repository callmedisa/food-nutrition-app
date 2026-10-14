import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_nutrition_app/core_providers.dart';
import 'package:food_nutrition_app/features/diary/domain/entities/diary_entry.dart';
import 'package:food_nutrition_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:food_nutrition_app/features/diary/presentation/notifiers/diary_notifier.dart';
import 'package:food_nutrition_app/features/diary/presentation/notifiers/stats_notifier.dart';
import 'package:food_nutrition_app/features/nutrition/domain/entities/food_product.dart';

/// In-memory diary so the test does not need SQLite.
class FakeDiaryRepository implements DiaryRepository {
  final _meals = <DiaryEntry>[];
  int _nextId = 1;

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  Future<List<DiaryEntry>> getMealsForDate(DateTime date) async =>
      _meals.where((m) => _day(m.time) == _day(date)).toList();

  @override
  Future<DiaryEntry> insertMeal(DiaryEntry entry) async {
    final saved = DiaryEntry(id: _nextId++, food: entry.food, grams: entry.grams, time: entry.time);
    _meals.add(saved);
    return saved;
  }

  @override
  Future<void> deleteMeal(int id, DateTime date) async => _meals.removeWhere((m) => m.id == id);

  @override
  Future<Map<DateTime, double>> getCaloriesPerDay(int days) async {
    final result = <DateTime, double>{};
    for (final m in _meals) {
      result.update(_day(m.time), (v) => v + m.calories, ifAbsent: () => m.calories);
    }
    return result;
  }
}

const _beshbarmak = FoodProduct(
  id: 'beshbarmak',
  name: 'Beshbarmak',
  nameRu: 'Бешбармак',
  nameKz: 'Бешбармақ',
  calories: 248,
  protein: 15,
  fat: 12,
  carbs: 20,
  category: 'kazakh',
  emoji: '🍖',
);

double _total(Map<DateTime, double> stats) => stats.values.fold(0, (a, b) => a + b);

void main() {
  test('weekly stats follow meals added and deleted in the diary', () async {
    final container = ProviderContainer(
      overrides: [diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository())],
    );
    addTearDown(container.dispose);
    // Keep the stats provider alive, as the stats screen does.
    container.listen(statsNotifierProvider, (_, __) {});

    expect(_total(await container.read(statsNotifierProvider.future)), 0);

    await container.read(diaryNotifierProvider.future);
    await container
        .read(diaryNotifierProvider.notifier)
        .addMeal(DiaryEntry(food: _beshbarmak, grams: 350, time: DateTime.now()));

    expect(_total(await container.read(statsNotifierProvider.future)), closeTo(868, 0.01));

    final meal = (await container.read(diaryNotifierProvider.future)).single;
    await container.read(diaryNotifierProvider.notifier).deleteMeal(meal.id!, meal.time);

    expect(_total(await container.read(statsNotifierProvider.future)), 0);
  });
}
