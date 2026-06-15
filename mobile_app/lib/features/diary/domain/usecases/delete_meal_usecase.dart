import '../repositories/diary_repository.dart';

class DeleteMealUseCase {
  final DiaryRepository _repository;
  DeleteMealUseCase(this._repository);

  Future<void> call(int id, DateTime date) => _repository.deleteMeal(id, date);
}