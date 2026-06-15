import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../nutrition/domain/entities/food_product.dart';
import '../../domain/entities/classification_result.dart';

class ApiDataSource {
  String get _baseUrl {
    if (kIsWeb) return 'http://${Uri.base.host}:8000';
    return 'http://localhost:8000';
  }

  Future<bool> isAvailable() async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/')).timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<ClassificationResult>> recognize(Uint8List imageBytes) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      if (attempt > 1) await Future.delayed(const Duration(seconds: 5));
      try {
        final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/recognize'));
        req.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'food.jpg'));
        final streamed = await req.send().timeout(const Duration(seconds: 45));
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseResponse(data);
        }

        // 422 = «не еда» или «низкая уверенность» — не повторяем, показываем сразу
        if (response.statusCode == 422) {
          final err = _tryParseError(response.body) ?? 'На фото не удалось распознать еду.';
          throw FoodNotDetectedException(err);
        }

        // 503/504 — модель ещё не готова, повторяем
        if ((response.statusCode == 503 || response.statusCode == 504) && attempt < 3) {
          continue;
        }

        final err = _tryParseError(response.body) ?? 'Ошибка сервера ${response.statusCode}';
        throw Exception(err);
      } on FoodNotDetectedException {
        rethrow;
      } on TimeoutException {
        if (attempt < 3) continue;
        throw Exception('Превышено время ожидания. Попробуй ещё раз через 30 секунд.');
      }
    }
    throw Exception('Сервер не ответил после 3 попыток');
  }

  List<ClassificationResult> _parseResponse(Map<String, dynamic> data) {
    final predictions = data['all_predictions'] as List<dynamic>;
    return predictions.map((p) {
      final n = p['nutrition'] as Map<String, dynamic>;
      return ClassificationResult(
        food: FoodProduct(
          id: p['label'] as String,
          name: p['label'] as String,
          nameRu: n['nameRu'] as String,
          nameKz: (n['nameKz'] as String?) ?? '',
          calories: (n['calories'] as num).toDouble(),
          protein: (n['protein'] as num).toDouble(),
          fat: (n['fat'] as num).toDouble(),
          carbs: (n['carbs'] as num).toDouble(),
          category: 'recognized',
          emoji: (n['emoji'] as String?) ?? '🍽️',
        ),
        confidence: (p['confidence'] as num).toInt(),
        source: (p['source'] as String?) ?? 'api',
      );
    }).toList();
  }

  String? _tryParseError(String body) {
    try {
      return (jsonDecode(body) as Map)['detail'] as String?;
    } catch (_) {
      return null;
    }
  }
}

// Специальное исключение для случая "не еда"
class FoodNotDetectedException implements Exception {
  final String message;
  FoodNotDetectedException(this.message);

  @override
  String toString() => message;
}