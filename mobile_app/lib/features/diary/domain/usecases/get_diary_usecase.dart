import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class GetDiaryUseCase {
  final DiaryRepository _repository;
  GetDiaryUseCase(this._repository);

  Future<List<DiaryEntry>> call(DateTime date) => _repository.getMealsForDate(date);
}