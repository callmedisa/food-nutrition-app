import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../domain/entities/classification_result.dart';
import '../../domain/repositories/classification_repository.dart';
import '../datasources/api_datasource.dart';
import '../datasources/platform_channel_datasource.dart';

// Двухуровневый классификатор:
//   1. Приоритет: TFLite офлайн через Platform Channel (если модель загружена)
//   2. Резерв: FastAPI сервер (HTTP)
class ClassificationRepositoryImpl implements ClassificationRepository {
  final PlatformChannelDataSource _tflite;
  final ApiDataSource _api;

  ClassificationRepositoryImpl(this._tflite, this._api);

  @override
  Future<List<ClassificationResult>> classify(Uint8List imageBytes) async {
    // Попытка 1 — офлайн TFLite через Platform Channel
    if (_tflite.isModelLoaded) {
      try {
        final preds = await _tflite.classifyImage(imageBytes);
        if (preds.isNotEmpty) {
          // Platform Channel вернул лейблы — дополняем через API
          // (нутриенты в нативной части не хранятся)
        }
      } on PlatformException {
        // Модель не отвечает — переходим к API
      }
    }

    // Попытка 2 — HTTP к FastAPI (основной путь пока .tflite-файл не добавлен)
    return _api.recognize(imageBytes);
  }
}