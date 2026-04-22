import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../widgets/macro_ring.dart';
import '../widgets/meal_card.dart';
import 'add_food_screen.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MealEntry> _meals = [];
  final int _calorieGoal = 2000;

  double get _totalCalories => _meals.fold(0, (s, m) => s + m.calories);
  double get _totalProtein => _meals.fold(0, (s, m) => s + m.protein);
  double get _totalFat => _meals.fold(0, (s, m) => s + m.fat);
  double get _totalCarbs => _meals.fold(0, (s, m) => s + m.carbs);

  void _addMeal(MealEntry entry) {
    setState(() => _meals.add(entry));
  }

  void _removeMeal(int index) {
    setState(() => _meals.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMMM, EEEE', 'ru').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            backgroundColor: const Color(0xFF4CAF82),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NutriScan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                Text(today, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                onPressed: () async {
                  final entry = await Navigator.push<MealEntry>(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                  if (entry != null) _addMeal(entry);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCalorieCard(),
                  const SizedBox(height: 16),
                  _buildMacroRow(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Приёмы пищи', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${_meals.length} записей', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _meals.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: MealCard(
                        entry: _meals[i],
                        onDelete: () => _removeMeal(i),
                      ),
                    ),
                    childCount: _meals.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF82),
        onPressed: () async {
          final entry = await Navigator.push<MealEntry>(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodScreen()),
          );
          if (entry != null) _addMeal(entry);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Добавить еду', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCalorieCard() {
    final remaining = (_calorieGoal - _totalCalories).clamp(0, _calorieGoal).toInt();
    final progress = (_totalCalories / _calorieGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF82), Color(0xFF2E7D5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4CAF82).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Калории', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('${_totalCalories.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                  Text('из $_calorieGoal ккал', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              MacroRing(
                calories: _totalCalories,
                goal: _calorieGoal.toDouble(),
                size: 90,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Осталось: $remaining ккал', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Сожжено: 0 ккал', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      children: [
        Expanded(child: _macroCard('Белки', _totalProtein, 150, const Color(0xFF5B8BF5))),
        const SizedBox(width: 8),
        Expanded(child: _macroCard('Жиры', _totalFat, 65, const Color(0xFFFF8C42))),
        const SizedBox(width: 8),
        Expanded(child: _macroCard('Углеводы', _totalCarbs, 250, const Color(0xFFF5C842))),
      ],
    );
  }

  Widget _macroCard(String label, double value, int goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text('${value.toInt()} г', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('из $goal г', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text('🍽️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Нет записей о еде', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            const Text('Нажмите «Добавить еду» или\nсделайте фото блюда', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}
