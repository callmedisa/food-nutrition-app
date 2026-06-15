import '../../../nutrition/domain/entities/food_product.dart';

class DiaryEntry {
  final int? id;
  final FoodProduct food;
  final double grams;
  final DateTime time;

  const DiaryEntry({
    this.id,
    required this.food,
    required this.grams,
    required this.time,
  });

  double get calories => food.calories * grams / 100;
  double get protein  => food.protein  * grams / 100;
  double get fat      => food.fat      * grams / 100;
  double get carbs    => food.carbs    * grams / 100;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'food_id': food.id,
    'food_name': food.name,
    'food_name_ru': food.nameRu,
    'food_name_kz': food.nameKz,
    'food_calories': food.calories,
    'food_protein': food.protein,
    'food_fat': food.fat,
    'food_carbs': food.carbs,
    'food_category': food.category,
    'food_emoji': food.emoji,
    'grams': grams,
    'timestamp': time.millisecondsSinceEpoch,
  };

  factory DiaryEntry.fromMap(Map<String, dynamic> m) => DiaryEntry(
    id: m['id'] as int?,
    food: FoodProduct(
      id: m['food_id'] as String,
      name: m['food_name'] as String,
      nameRu: m['food_name_ru'] as String,
      nameKz: (m['food_name_kz'] as String?) ?? '',
      calories: (m['food_calories'] as num).toDouble(),
      protein: (m['food_protein'] as num).toDouble(),
      fat: (m['food_fat'] as num).toDouble(),
      carbs: (m['food_carbs'] as num).toDouble(),
      category: m['food_category'] as String,
      emoji: m['food_emoji'] as String,
    ),
    grams: (m['grams'] as num).toDouble(),
    time: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
  );
}