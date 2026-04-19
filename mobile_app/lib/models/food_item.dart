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
  final FoodItem food;
  final double grams;
  final DateTime time;

  MealEntry({
    required this.food,
    required this.grams,
    required this.time,
  });

  double get calories => food.calories * grams / 100;
  double get protein => food.protein * grams / 100;
  double get fat => food.fat * grams / 100;
  double get carbs => food.carbs * grams / 100;
}
