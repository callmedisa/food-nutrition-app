import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core_providers.dart';
import '../../domain/entities/diary_entry.dart';

// DiaryNotifier — управляет списком приёмов пищи за текущий день (MVVM ViewModel).
class DiaryNotifier extends AsyncNotifier<List<DiaryEntry>> {
  @override
  Future<List<DiaryEntry>> build() =>
      ref.read(getDiaryUseCaseProvider).call(DateTime.now());

  Future<void> addMeal(DiaryEntry entry) async {
    final saved = await ref.read(addMealUseCaseProvider).call(entry);
    state = AsyncValue.data([...state.valueOrNull ?? [], saved]);
  }

  Future<void> deleteMeal(int id, DateTime date) async {
    await ref.read(deleteMealUseCaseProvider).call(id, date);
    state = AsyncValue.data(
      (state.valueOrNull ?? []).where((e) => e.id != id).toList(),
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getDiaryUseCaseProvider).call(DateTime.now()),
    );
  }
}

final diaryNotifierProvider =
    AsyncNotifierProvider<DiaryNotifier, List<DiaryEntry>>(DiaryNotifier.new);