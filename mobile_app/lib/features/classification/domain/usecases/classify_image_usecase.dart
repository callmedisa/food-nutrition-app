import 'dart:typed_data';
import '../entities/classification_result.dart';
import '../repositories/classification_repository.dart';

class ClassifyImageUseCase {
  final ClassificationRepository _repository;
  ClassifyImageUseCase(this._repository);

  Future<List<ClassificationResult>> call(Uint8List imageBytes) =>
      _repository.classify(imageBytes);
}