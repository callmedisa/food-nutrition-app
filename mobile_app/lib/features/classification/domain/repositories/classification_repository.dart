import 'dart:typed_data';
import '../entities/classification_result.dart';

abstract class ClassificationRepository {
  Future<List<ClassificationResult>> classify(Uint8List imageBytes);
}