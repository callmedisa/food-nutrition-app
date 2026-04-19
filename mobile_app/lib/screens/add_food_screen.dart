import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/food_database.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchCtrl = TextEditingController();
  final _gramsCtrl = TextEditingController(text: '100');
  List<FoodItem> _results = FoodDatabase.items;
  FoodItem? _selected;

  void _search(String q) {
    setState(() => _results = FoodDatabase.search(q));
  }

  void _confirm() {
    if (_selected == null) return;
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    final entry = MealEntry(food: _selected!, grams: grams, time: DateTime.now());
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        title: const Text('Добавить еду'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF4CAF82),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Поиск продукта...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          if (_selected != null) _buildNutritionPreview(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              itemBuilder: (ctx, i) {
                final item = _results[i];
                final isSelected = _selected?.id == item.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4CAF82).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4CAF82) : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nameRu, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              Text(item.name, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${item.calories.toInt()} ккал', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF82))),
                            Text('на 100 г', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selected != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF82),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Добавить в дневник', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNutritionPreview() {
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    final f = _selected!;
    final cal = f.calories * grams / 100;
    final p = f.protein * grams / 100;
    final fat = f.fat * grams / 100;
    final c = f.carbs * grams / 100;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(f.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(f.nameRu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _gramsCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    suffixText: 'г',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('Калории', '${cal.toInt()}', 'ккал', const Color(0xFF4CAF82)),
              _stat('Белки', '${p.toStringAsFixed(1)}', 'г', const Color(0xFF5B8BF5)),
              _stat('Жиры', '${fat.toStringAsFixed(1)}', 'г', const Color(0xFFFF8C42)),
              _stat('Углеводы', '${c.toStringAsFixed(1)}', 'г', const Color(0xFFF5C842)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(unit, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }
}
