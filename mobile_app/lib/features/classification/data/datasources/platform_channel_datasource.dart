import 'dart:typed_data';
import 'package:flutter/services.dart';

// Platform Channel для TFLite-инференса на устройстве (офлайн-режим).
// Канал: 'com.nutriscan/tflite_classifier'
// Нативный код реализован в:
//   Android → android/app/src/main/kotlin/.../MainActivity.kt
//   iOS     → ios/Runner/AppDelegate.swift
class PlatformChannelDataSource {
  static const _channel = MethodChannel('com.nutriscan/tflite_classifier');

  bool _modelLoaded = false;

  Future<bool> loadModel({
    String modelPath = 'assets/models/kazakh_model.tflite',
    String labelsPath = 'assets/models/kazakh_labels.txt',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('loadModel', {
        'modelPath': modelPath,
        'labelsPath': labelsPath,
      });
      _modelLoaded = (result?['status'] == 'loaded');
      return _modelLoaded;
    } on PlatformException {
      _modelLoaded = false;
      return false;
    }
  }

  // Возвращает список {'label': String, 'confidence': int} или пробрасывает исключение
  Future<List<Map<String, dynamic>>> classifyImage(Uint8List imageBytes) async {
    if (!_modelLoaded) throw PlatformException(code: 'MODEL_NOT_LOADED');
    final result = await _channel.invokeMethod<Map>('classifyImage', {
      'imageBytes': imageBytes,
    });
    final predictions = (result?['predictions'] as List?) ?? [];
    return predictions
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
  }

  bool get isModelLoaded => _modelLoaded;
}