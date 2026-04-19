import '../models/food_item.dart';

class FoodDatabase {
  static const List<FoodItem> items = [
    // Зерновые
    FoodItem(id: '1', name: 'Rice (cooked)', nameRu: 'Рис варёный', calories: 130, protein: 2.7, fat: 0.3, carbs: 28.2, category: 'grain', emoji: '🍚'),
    FoodItem(id: '2', name: 'Oatmeal', nameRu: 'Овсяная каша', calories: 88, protein: 3.2, fat: 1.7, carbs: 15.0, category: 'grain', emoji: '🥣'),
    FoodItem(id: '3', name: 'Bread (white)', nameRu: 'Хлеб белый', calories: 265, protein: 9.0, fat: 3.2, carbs: 51.4, category: 'grain', emoji: '🍞'),
    FoodItem(id: '4', name: 'Pasta (cooked)', nameRu: 'Макароны варёные', calories: 158, protein: 5.8, fat: 0.9, carbs: 30.9, category: 'grain', emoji: '🍝'),
    FoodItem(id: '5', name: 'Buckwheat', nameRu: 'Гречка варёная', calories: 110, protein: 4.2, fat: 1.1, carbs: 21.3, category: 'grain', emoji: '🌾'),

    // Мясо и рыба
    FoodItem(id: '6', name: 'Chicken breast', nameRu: 'Куриная грудка', calories: 165, protein: 31.0, fat: 3.6, carbs: 0.0, category: 'meat', emoji: '🍗'),
    FoodItem(id: '7', name: 'Beef', nameRu: 'Говядина', calories: 250, protein: 26.1, fat: 16.0, carbs: 0.0, category: 'meat', emoji: '🥩'),
    FoodItem(id: '8', name: 'Salmon', nameRu: 'Лосось', calories: 208, protein: 20.4, fat: 13.4, carbs: 0.0, category: 'fish', emoji: '🐟'),
    FoodItem(id: '9', name: 'Tuna (canned)', nameRu: 'Тунец (консерва)', calories: 116, protein: 25.5, fat: 1.0, carbs: 0.0, category: 'fish', emoji: '🐠'),
    FoodItem(id: '10', name: 'Egg', nameRu: 'Яйцо', calories: 155, protein: 13.0, fat: 11.0, carbs: 1.1, category: 'egg', emoji: '🥚'),

    // Молочные
    FoodItem(id: '11', name: 'Milk (2.5%)', nameRu: 'Молоко 2.5%', calories: 52, protein: 2.8, fat: 2.5, carbs: 4.7, category: 'dairy', emoji: '🥛'),
    FoodItem(id: '12', name: 'Greek yogurt', nameRu: 'Греческий йогурт', calories: 97, protein: 9.0, fat: 5.0, carbs: 3.9, category: 'dairy', emoji: '🧁'),
    FoodItem(id: '13', name: 'Cottage cheese', nameRu: 'Творог 5%', calories: 121, protein: 17.2, fat: 5.0, carbs: 1.8, category: 'dairy', emoji: '🫙'),
    FoodItem(id: '14', name: 'Cheese (cheddar)', nameRu: 'Сыр чеддер', calories: 403, protein: 25.0, fat: 33.0, carbs: 1.3, category: 'dairy', emoji: '🧀'),

    // Овощи
    FoodItem(id: '15', name: 'Tomato', nameRu: 'Помидор', calories: 18, protein: 0.9, fat: 0.2, carbs: 3.9, category: 'vegetable', emoji: '🍅'),
    FoodItem(id: '16', name: 'Cucumber', nameRu: 'Огурец', calories: 15, protein: 0.7, fat: 0.1, carbs: 3.6, category: 'vegetable', emoji: '🥒'),
    FoodItem(id: '17', name: 'Potato (boiled)', nameRu: 'Картофель варёный', calories: 77, protein: 2.0, fat: 0.1, carbs: 17.0, category: 'vegetable', emoji: '🥔'),
    FoodItem(id: '18', name: 'Broccoli', nameRu: 'Брокколи', calories: 34, protein: 2.8, fat: 0.4, carbs: 6.6, category: 'vegetable', emoji: '🥦'),
    FoodItem(id: '19', name: 'Carrot', nameRu: 'Морковь', calories: 41, protein: 0.9, fat: 0.2, carbs: 9.6, category: 'vegetable', emoji: '🥕'),

    // Фрукты
    FoodItem(id: '20', name: 'Apple', nameRu: 'Яблоко', calories: 52, protein: 0.3, fat: 0.2, carbs: 13.8, category: 'fruit', emoji: '🍎'),
    FoodItem(id: '21', name: 'Banana', nameRu: 'Банан', calories: 89, protein: 1.1, fat: 0.3, carbs: 22.8, category: 'fruit', emoji: '🍌'),
    FoodItem(id: '22', name: 'Orange', nameRu: 'Апельсин', calories: 47, protein: 0.9, fat: 0.1, carbs: 11.8, category: 'fruit', emoji: '🍊'),

    // Орехи и бобовые
    FoodItem(id: '23', name: 'Almonds', nameRu: 'Миндаль', calories: 579, protein: 21.2, fat: 49.9, carbs: 21.6, category: 'nut', emoji: '🌰'),
    FoodItem(id: '24', name: 'Lentils (cooked)', nameRu: 'Чечевица варёная', calories: 116, protein: 9.0, fat: 0.4, carbs: 20.1, category: 'legume', emoji: '🫘'),
  ];

  static List<FoodItem> search(String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((f) =>
      f.nameRu.toLowerCase().contains(q) ||
      f.name.toLowerCase().contains(q)
    ).toList();
  }
}
