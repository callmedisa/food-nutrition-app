import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';
import '../../../../providers.dart';
import '../../../diary/domain/entities/diary_entry.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 800);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
      ref.read(classificationNotifierProvider.notifier).reset();
      ref.read(classificationNotifierProvider.notifier).classify(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _addToDiary() {
    final state = ref.read(classificationNotifierProvider);
    if (state.results.isEmpty) return;
    final result = state.results[state.selectedIndex];
    final entry  = DiaryEntry(food: result.food, grams: 100, time: DateTime.now());
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final state = ref.watch(classificationNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(l.cameraTitle),
      ),
      body: Stack(children: [
        // Background
        Container(
          width: double.infinity, height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
          child: _imageBytes != null
              ? Opacity(opacity: 0.5, child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity))
              : Center(
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 260, height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF4CAF82), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white30),
                          const SizedBox(height: 12),
                          Text(l.cameraHint, textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white38, fontSize: 16)),
                        ]),
                      ),
                    ),
                  ),
                ),
        ),
        // Analyzing overlay
        if (state.isAnalyzing)
          Container(
            color: Colors.black54,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(color: Color(0xFF4CAF82)),
              const SizedBox(height: 20),
              Text(l.cameraAnalyzing, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              Text(l.cameraProcessing, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ])),
          ),
        // Error banner
        if (!state.isAnalyzing && state.error != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _ErrorBanner(
              error: state.error!,
              onRetry: () {
                ref.read(classificationNotifierProvider.notifier).reset();
                setState(() => _imageBytes = null);
              },
              retryLabel: l.cameraRetry,
            ),
          ),
        // Result sheet
        if (!state.isAnalyzing && state.results.isNotEmpty)
          _ResultSheet(state: state, l: l, onAddToDiary: _addToDiary, onReset: () {
            ref.read(classificationNotifierProvider.notifier).reset();
            setState(() => _imageBytes = null);
          }),
        // Buttons
        if (!state.isAnalyzing && state.results.isEmpty && state.error == null)
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF82),
                    boxShadow: [BoxShadow(color: const Color(0xFF4CAF82).withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 12),
              Text(l.cameraTakePhoto, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, color: Colors.white54),
                label: Text(l.cameraGallery, style: const TextStyle(color: Colors.white54)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _ResultSheet extends ConsumerWidget {
  final ClassificationState state;
  final AppLocalizations l;
  final VoidCallback onAddToDiary;
  final VoidCallback onReset;

  const _ResultSheet({required this.state, required this.l, required this.onAddToDiary, required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider).valueOrNull;
    final langCode = locale?.languageCode ?? 'ru';
    final results = state.results;
    final selected = results[state.selectedIndex];
    final food = selected.food;
    final confidence = selected.confidence;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          // Recognized food header
          Row(children: [
            Text(food.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.cameraRecognized, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(food.localName(langCode), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              Row(children: [
                Icon(Icons.verified, size: 14,
                    color: confidence >= 70 ? Colors.green[600] : Colors.orange[600]),
                const SizedBox(width: 4),
                Text(
                  l.cameraConfidence(confidence),
                  style: TextStyle(
                    color: confidence >= 70 ? Colors.green[600] : Colors.orange[600],
                    fontSize: 12, fontWeight: FontWeight.w600,
                  ),
                ),
              ]),
            ])),
          ]),
          const SizedBox(height: 12),
          // Nutrition grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat(l.labelCalories, '${food.calories.toInt()}', l.labelKcal, const Color(0xFF4CAF82)),
              _stat(l.labelProtein,  '${food.protein.toInt()}',  l.labelGrams, const Color(0xFF5B8BF5)),
              _stat(l.labelFat,      '${food.fat.toInt()}',      l.labelGrams, const Color(0xFFFF8C42)),
              _stat(l.labelCarbs,    '${food.carbs.toInt()}',    l.labelGrams, const Color(0xFFF5C842)),
            ]),
          ),
          const SizedBox(height: 4),
          Text(l.labelPer100g, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          // Alternative predictions (when confidence < 90%)
          if (results.length > 1 && confidence < 90) ...[
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerLeft,
              child: Text(l.cameraAlternatives, style: const TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 8),
            ...results.take(3).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isSelected = i == state.selectedIndex;
              return GestureDetector(
                onTap: () => ref.read(classificationNotifierProvider.notifier).selectResult(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F5EE) : Colors.grey[50],
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF82) : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Text(r.food.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r.food.localName(langCode),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                          color: isSelected ? const Color(0xFF2E7D5E) : Colors.black87,
                        ))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4CAF82) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${r.confidence}%',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          )),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF82), size: 18),
                    ],
                  ]),
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF82),
                  side: const BorderSide(color: Color(0xFF4CAF82)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l.cameraTryAgain),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onAddToDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF82), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l.cameraAddToDiary, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, String unit, Color color) => Column(children: [
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
    Text(unit,  style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ]);
}

// Баннер ошибки с умным отображением:
// - "не еда" → специальная иконка + подсказка сфотографировать еду
// - другие ошибки → стандартная иконка ошибки
class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String retryLabel;

  const _ErrorBanner({required this.error, required this.onRetry, required this.retryLabel});

  bool get _isNotFoodError {
    final lower = error.toLowerCase();
    return lower.contains('не удалось распознать') ||
        lower.contains('не еда') ||
        lower.contains('не является едой') ||
        lower.contains('низкой уверенностью') ||
        lower.contains('на фото не');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Иконка зависит от типа ошибки
        if (_isNotFoodError) ...[
          const Text('🤔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          const Text(
            'На фото не еда',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          // Подсказки что нужно делать
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF82).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF82).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Советы:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                _tip('📸', 'Сфотографируйте только еду, без лишних предметов'),
                _tip('💡', 'Хорошее освещение улучшает точность'),
                _tip('🔍', 'Блюдо должно занимать большую часть кадра'),
              ],
            ),
          ),
        ] else ...[
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(retryLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }

  Widget _tip(String emoji, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
    ]),
  );
}