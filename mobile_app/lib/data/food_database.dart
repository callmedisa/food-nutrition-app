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

    // Казахская кухня
    FoodItem(id: 'kz1', name: 'Beshbarmak', nameRu: 'Бешбармак', calories: 248, protein: 15.2, fat: 11.8, carbs: 20.4, category: 'kazakh', emoji: '🍖'),
    FoodItem(id: 'kz2', name: 'Kuirdak', nameRu: 'Куырдак', calories: 218, protein: 14.0, fat: 15.2, carbs: 5.1, category: 'kazakh', emoji: '🥘'),
    FoodItem(id: 'kz3', name: 'Bauyrsak', nameRu: 'Баурсак', calories: 378, protein: 7.2, fat: 17.8, carbs: 46.3, category: 'kazakh', emoji: '🟡'),
    FoodItem(id: 'kz4', name: 'Lagman', nameRu: 'Лагман', calories: 138, protein: 7.8, fat: 5.6, carbs: 14.2, category: 'kazakh', emoji: '🍜'),
    FoodItem(id: 'kz5', name: 'Manty', nameRu: 'Манты', calories: 198, protein: 10.2, fat: 9.8, carbs: 18.5, category: 'kazakh', emoji: '🥟'),
    FoodItem(id: 'kz6', name: 'Samsa', nameRu: 'Самса', calories: 298, protein: 10.4, fat: 14.6, carbs: 30.2, category: 'kazakh', emoji: '🫓'),
    FoodItem(id: 'kz7', name: 'Sorpa', nameRu: 'Сорпа', calories: 48, protein: 4.2, fat: 2.1, carbs: 2.4, category: 'kazakh', emoji: '🍲'),
    FoodItem(id: 'kz8', name: 'Kazy', nameRu: 'Қазы', calories: 422, protein: 15.8, fat: 38.4, carbs: 1.2, category: 'kazakh', emoji: '🌭'),
    FoodItem(id: 'kz9', name: 'Naryn', nameRu: 'Нарын', calories: 196, protein: 12.4, fat: 9.6, carbs: 14.8, category: 'kazakh', emoji: '🍝'),
    FoodItem(id: 'kz10', name: 'Shelpek', nameRu: 'Шелпек', calories: 302, protein: 6.1, fat: 11.8, carbs: 42.6, category: 'kazakh', emoji: '🫓'),
    FoodItem(id: 'kz11', name: 'Plov', nameRu: 'Плов', calories: 222, protein: 8.2, fat: 10.4, carbs: 25.8, category: 'kazakh', emoji: '🍛'),
    FoodItem(id: 'kz12', name: 'Shashlik', nameRu: 'Шашлык', calories: 218, protein: 22.1, fat: 13.6, carbs: 1.0, category: 'kazakh', emoji: '🍢'),
    FoodItem(id: 'kz13', name: 'Kumiss', nameRu: 'Қымыз', calories: 50, protein: 2.1, fat: 1.9, carbs: 5.2, category: 'kazakh', emoji: '🥛'),
    FoodItem(id: 'kz14', name: 'Shubat', nameRu: 'Шұбат', calories: 58, protein: 3.2, fat: 2.8, carbs: 4.4, category: 'kazakh', emoji: '🥛'),
    FoodItem(id: 'kz15', name: 'Kurt', nameRu: 'Құрт', calories: 260, protein: 25.4, fat: 8.2, carbs: 18.6, category: 'kazakh', emoji: '⚪'),
    FoodItem(id: 'kz16', name: 'Zhent', nameRu: 'Жент', calories: 388, protein: 8.4, fat: 14.2, carbs: 56.8, category: 'kazakh', emoji: '🟤'),
    FoodItem(id: 'kz17', name: 'Irimshik', nameRu: 'Іріімшік', calories: 168, protein: 14.8, fat: 9.2, carbs: 6.4, category: 'kazakh', emoji: '🧀'),
    FoodItem(id: 'kz18', name: 'Zhayma', nameRu: 'Жайма (тесто для бешбармака)', calories: 285, protein: 9.2, fat: 2.8, carbs: 56.4, category: 'kazakh', emoji: '🫓'),
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
