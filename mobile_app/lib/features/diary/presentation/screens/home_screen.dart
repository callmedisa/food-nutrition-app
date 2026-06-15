import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';
import '../../../../providers.dart';
import '../../../classification/presentation/screens/camera_screen.dart';
import '../../../nutrition/presentation/screens/add_food_screen.dart';
import '../widgets/macro_ring.dart';
import '../widgets/meal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider).valueOrNull;
    final langCode = locale?.languageCode ?? 'ru';
    final diaryAsync = ref.watch(diaryNotifierProvider);
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    final calorieGoal = profile?.calorieGoal ?? 2000;
    final proteinGoal = profile?.proteinGoal ?? 150;
    final fatGoal     = profile?.fatGoal     ?? 65;
    final carbGoal    = profile?.carbGoal    ?? 250;

    final today = DateFormat('d MMMM, EEEE', langCode == 'kk' ? 'ru' : langCode)
        .format(DateTime.now());

    return Scaffold(
      body: diaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (meals) {
          final totalCal  = meals.fold(0.0, (s, m) => s + m.calories);
          final totalProt = meals.fold(0.0, (s, m) => s + m.protein);
          final totalFat  = meals.fold(0.0, (s, m) => s + m.fat);
          final totalCarb = meals.fold(0.0, (s, m) => s + m.carbs);
          return RefreshIndicator(
            onRefresh: () => ref.read(diaryNotifierProvider.notifier).reload(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 60,
                  floating: true,
                  backgroundColor: const Color(0xFF4CAF82),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.appTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      Text(today, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      onPressed: () async {
                        final entry = await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CameraScreen()));
                        if (entry != null && context.mounted) {
                          ref.read(diaryNotifierProvider.notifier).addMeal(entry);
                        }
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _CalorieCard(total: totalCal, goal: calorieGoal, profileName: profile?.name, l: l),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: _MacroCard(label: l.labelProtein, value: totalProt, goal: proteinGoal, color: const Color(0xFF5B8BF5), l: l)),
                          const SizedBox(width: 8),
                          Expanded(child: _MacroCard(label: l.labelFat,     value: totalFat,  goal: fatGoal,     color: const Color(0xFFFF8C42), l: l)),
                          const SizedBox(width: 8),
                          Expanded(child: _MacroCard(label: l.labelCarbs,   value: totalCarb, goal: carbGoal,    color: const Color(0xFFF5C842), l: l)),
                        ]),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l.homeMeals, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(l.homeMealsCount(meals.length), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (meals.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(children: [
                          const Text('🍽️', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 12),
                          Text(l.homeEmpty, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Text(l.homeEmptyHint, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black38)),
                        ]),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: MealCard(
                          entry: meals[i],
                          onDelete: () => ref.read(diaryNotifierProvider.notifier)
                              .deleteMeal(meals[i].id!, meals[i].time),
                        ),
                      ),
                      childCount: meals.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF82),
        onPressed: () async {
          final entry = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddFoodScreen()));
          if (entry != null && context.mounted) {
            ref.read(diaryNotifierProvider.notifier).addMeal(entry);
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.homeAddFood, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CalorieCard extends StatelessWidget {
  final double total;
  final int goal;
  final String? profileName;
  final AppLocalizations l;

  const _CalorieCard({required this.total, required this.goal, this.profileName, required this.l});

  @override
  Widget build(BuildContext context) {
    final remaining = (goal - total).clamp(0, goal).toInt();
    final progress  = (total / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF82), Color(0xFF2E7D5E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4CAF82).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.labelCalories, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${total.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              Text(l.homeCaloriesOf(goal), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
            MacroRing(calories: total, goal: goal.toDouble(), size: 90),
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
            Text(l.homeRemaining(remaining), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(profileName ?? l.homeSetupProfile, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ]),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final int goal;
  final Color color;
  final AppLocalizations l;

  const _MacroCard({required this.label, required this.value, required this.goal, required this.color, required this.l});

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text('${value.toInt()} ${l.labelGrams}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(l.homeMacroOf(goal), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
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
      ]),
    );
  }
}