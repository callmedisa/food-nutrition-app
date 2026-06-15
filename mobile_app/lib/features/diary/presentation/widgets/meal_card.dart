import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../domain/entities/diary_entry.dart';

class MealCard extends ConsumerWidget {
  final DiaryEntry entry;
  final VoidCallback onDelete;

  const MealCard({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider).valueOrNull;
    final langCode = locale?.languageCode ?? 'ru';
    final displayName = entry.food.localName(langCode);

    return Dismissible(
      key: Key('meal_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(entry.food.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      '${entry.grams.toInt()} г  •  ${entry.calories.toInt()} ккал',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _macro('Б', entry.protein, const Color(0xFF5B8BF5)),
                  _macro('Ж', entry.fat,     const Color(0xFFFF8C42)),
                  _macro('У', entry.carbs,   const Color(0xFFF5C842)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macro(String label, double val, Color color) => Text(
    '$label ${val.toInt()}г',
    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
  );
}