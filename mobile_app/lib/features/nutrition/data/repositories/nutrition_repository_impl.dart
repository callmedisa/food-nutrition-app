import '../../domain/entities/food_product.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/food_database.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  @override
  List<FoodProduct> searchFood(String query) => FoodDatabase.search(query);

  @override
  List<FoodProduct> getAllFood() => FoodDatabase.items;

  @override
  FoodProduct? findById(String id) {
    try {
      return FoodDatabase.items.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}