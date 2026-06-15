import '../../../nutrition/domain/entities/food_product.dart';

class ClassificationResult {
  final FoodProduct food;
  final int confidence; // 0–100
  final String source;  // 'kazakh_model' | 'food101' | 'platform_channel' | 'api'

  const ClassificationResult({
    required this.food,
    required this.confidence,
    required this.source,
  });
}