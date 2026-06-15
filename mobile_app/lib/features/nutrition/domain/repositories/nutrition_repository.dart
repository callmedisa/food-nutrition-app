import '../entities/food_product.dart';

abstract class NutritionRepository {
  List<FoodProduct> searchFood(String query);
  List<FoodProduct> getAllFood();
  FoodProduct? findById(String id);
}