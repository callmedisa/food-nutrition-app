import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core_providers.dart';
import 'diary_notifier.dart';

// StatsNotifier — загружает калории за 7 дней для экрана статистики.
class StatsNotifier extends AsyncNotifier<Map<DateTime, double>> {
  @override
  Future<Map<DateTime, double>> build() {
    // Пересчитываем при каждом изменении дневника (добавили или удалили еду).
    // Без этого экран статистики показывал цифры с момента запуска приложения.
    ref.watch(diaryNotifierProvider);
    return ref.read(getWeeklyStatsUseCaseProvider).call(7);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getWeeklyStatsUseCaseProvider).call(7),
    );
  }
}

final statsNotifierProvider =
    AsyncNotifierProvider<StatsNotifier, Map<DateTime, double>>(
        StatsNotifier.new);