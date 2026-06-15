import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';
import '../../../../providers.dart';
import '../../../diary/domain/entities/diary_entry.dart';
import '../../../nutrition/domain/entities/food_product.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _searchCtrl = TextEditingController();
  final _gramsCtrl  = TextEditingController(text: '100');
  List<FoodProduct> _results = [];
  FoodProduct? _selected;

  @override
  void initState() {
    super.initState();
    _results = ref.read(searchFoodUseCaseProvider).call('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _gramsCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    setState(() => _results = ref.read(searchFoodUseCaseProvider).call(q));
  }

  void _confirm() {
    if (_selected == null) return;
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    Navigator.pop(context,
        DiaryEntry(food: _selected!, grams: grams, time: DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider).valueOrNull;
    final langCode = locale?.languageCode ?? 'ru';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        title: Text(l.addFoodTitle),
        elevation: 0,
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: const Color(0xFF4CAF82),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _search,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l.addFoodSearch,
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        // Nutrition preview
        if (_selected != null) _buildPreview(context, _selected!, langCode, l),
        // Food list
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
                    color: isSelected ? const Color(0xFF4CAF82).withOpacity(0.1) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF82) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: Row(children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.localName(langCode),
                            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                        Text('${item.calories.toInt()} ${l.labelKcal} / 100 ${l.labelGrams}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ]),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF4CAF82)),
                  ]),
                ),
              );
            },
          ),
        ),
        // Confirm button
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF82),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l.addFoodAdd, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
      ]),
    );
  }

  Widget _buildPreview(BuildContext ctx, FoodProduct item, String langCode, AppLocalizations l) {
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    final factor = grams / 100;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF82).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4CAF82), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(item.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Expanded(child: Text(item.localName(langCode),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _gramsCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l.addFoodServing,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _pv(l.labelCalories, (item.calories * factor).toInt(), l.labelKcal, const Color(0xFF4CAF82)),
          _pv(l.labelProtein,  (item.protein  * factor).round(), l.labelGrams, const Color(0xFF5B8BF5)),
          _pv(l.labelFat,      (item.fat       * factor).round(), l.labelGrams, const Color(0xFFFF8C42)),
          _pv(l.labelCarbs,    (item.carbs     * factor).round(), l.labelGrams, const Color(0xFFF5C842)),
        ]),
      ]),
    );
  }

  Widget _pv(String label, int value, String unit, Color color) => Column(children: [
    Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
    Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
    Text(unit, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
  ]);
}