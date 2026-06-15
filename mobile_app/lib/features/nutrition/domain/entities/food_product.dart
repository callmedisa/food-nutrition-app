class FoodProduct {
  final String id;
  final String name;    // English name
  final String nameRu;  // Russian name
  final String nameKz;  // Kazakh name
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String category;
  final String emoji;

  const FoodProduct({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.nameKz,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.category,
    required this.emoji,
  });

  // Localised display name
  String localName(String langCode) {
    switch (langCode) {
      case 'kk': return nameKz.isNotEmpty ? nameKz : nameRu;
      case 'en': return name;
      default:   return nameRu;
    }
  }
}