class FoodItem {
  final String id;
  final String name;
  final String nameRu;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String category;
  final String emoji;

  const FoodItem({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.category,
    required this.emoji,
  });
}

class MealEntry {
  final int? dbId; // unique id (timestamp-based), null until saved
  final FoodItem food;
  final double grams;
  final DateTime time;

  MealEntry({
    this.dbId,
    required this.food,
    required this.grams,
    required this.time,
  });

  double get calories => food.calories * grams / 100;
  double get protein => food.protein * grams / 100;
  double get fat => food.fat * grams / 100;
  double get carbs => food.carbs * grams / 100;

  Map<String, dynamic> toMap() => {
    'id': dbId,
    'food_id': food.id,
    'food_name': food.name,
    'food_name_ru': food.nameRu,
    'food_calories': food.calories,
    'food_protein': food.protein,
    'food_fat': food.fat,
    'food_carbs': food.carbs,
    'food_category': food.category,
    'food_emoji': food.emoji,
    'grams': grams,
    'timestamp': time.millisecondsSinceEpoch,
  };

  factory MealEntry.fromMap(Map<String, dynamic> m) => MealEntry(
    dbId: m['id'] as int?,
    food: FoodItem(
      id: m['food_id'] as String,
      name: m['food_name'] as String,
      nameRu: m['food_name_ru'] as String,
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
