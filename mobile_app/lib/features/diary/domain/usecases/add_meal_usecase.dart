import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class AddMealUseCase {
  final DiaryRepository _repository;
  AddMealUseCase(this._repository);

  Future<DiaryEntry> call(DiaryEntry entry) => _repository.insertMeal(entry);
}