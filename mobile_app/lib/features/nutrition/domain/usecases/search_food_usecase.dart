import '../entities/food_product.dart';
import '../repositories/nutrition_repository.dart';

class SearchFoodUseCase {
  final NutritionRepository _repository;
  SearchFoodUseCase(this._repository);

  List<FoodProduct> call(String query) =>
      query.isEmpty ? _repository.getAllFood() : _repository.searchFood(query);
}