import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';

class MealCard extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onDelete;

  const MealCard({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(entry.time);
    return Dismissible(
      key: Key(entry.hashCode.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF82).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(entry.food.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.food.nameRu, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('${entry.grams.toInt()} г • $time', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.calories.toInt()} ккал', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF82), fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _macroChip('Б ${entry.protein.toInt()}г', const Color(0xFF5B8BF5)),
                    const SizedBox(width: 4),
                    _macroChip('Ж ${entry.fat.toInt()}г', const Color(0xFFFF8C42)),
                    const SizedBox(width: 4),
                    _macroChip('У ${entry.carbs.toInt()}г', const Color(0xFFF5C842)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
