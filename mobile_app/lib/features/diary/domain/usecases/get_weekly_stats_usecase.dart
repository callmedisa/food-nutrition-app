import '../repositories/diary_repository.dart';

class GetWeeklyStatsUseCase {
  final DiaryRepository _repository;
  GetWeeklyStatsUseCase(this._repository);

  Future<Map<DateTime, double>> call(int days) => _repository.getCaloriesPerDay(days);
}