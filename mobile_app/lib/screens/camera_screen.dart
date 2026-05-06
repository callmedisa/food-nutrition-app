import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/food_item.dart';

// Автоматически берёт хост откуда загрузилось приложение:
// - браузер на компьютере → localhost:8000
// - браузер на телефоне (тот же WiFi) → 192.168.x.x:8000
String get _backendUrl {
  if (kIsWeb) {
    return 'http://${Uri.base.host}:8000';
  }
  return 'http://localhost:8000';
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  bool _analyzing = false;
  String? _errorMessage;
  String? _statusMessage;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _result;
  int _selectedIndex = 0;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
      setState(() {
        _imageBytes = bytes;
        _result = null;
        _errorMessage = null;
        _statusMessage = null;
        _selectedIndex = 0;
      });
      await _analyzeImage(bytes);
    } catch (e) {
      setState(() => _errorMessage = 'Не удалось выбрать изображение: $e');
    }
  }

  Future<bool> _checkBackend() async {
    try {
      final response = await http.get(Uri.parse('$_backendUrl/')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _analyzeImage(Uint8List bytes) async {
    setState(() { _analyzing = true; _errorMessage = null; _statusMessage = 'Проверяю сервер...'; });

    final backendOk = await _checkBackend();
    if (!backendOk) {
      setState(() {
        _analyzing = false;
        _statusMessage = null;
        _errorMessage = 'Backend не запущен.\n\nЗапусти сервер командой:\ncd backend && python -m uvicorn main:app --reload\n\nЕсли тестируешь на телефоне — замени localhost на IP компьютера в camera_screen.dart';
      });
      return;
    }

    setState(() => _statusMessage = 'Отправляю изображение...');

    // Пробуем до 3 раз (HuggingFace модель может быть не прогрета)
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        if (attempt > 1) {
          setState(() => _statusMessage = 'Модель прогревается, попытка $attempt/3...');
          await Future.delayed(const Duration(seconds: 5));
        }

        final request = http.MultipartRequest('POST', Uri.parse('$_backendUrl/recognize'));
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'food.jpg'));

        final streamed = await request.send().timeout(const Duration(seconds: 45));
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          setState(() { _result = data; _analyzing = false; _statusMessage = null; });
          return;
        }

        if (response.statusCode == 503 || response.statusCode == 504) {
          // Модель ещё грузится — попробуем снова
          if (attempt < 3) continue;
        }

        // Другие ошибки — показываем сразу
        String detail = 'Ошибка сервера ${response.statusCode}';
        try {
          final err = jsonDecode(response.body);
          detail = err['detail'] ?? detail;
        } catch (_) {}
        setState(() { _errorMessage = detail; _analyzing = false; _statusMessage = null; });
        return;

      } on TimeoutException {
        if (attempt < 3) continue;
        setState(() {
          _errorMessage = 'Превышено время ожидания.\nМодель долго прогревается — попробуй ещё раз через 30 секунд.';
          _analyzing = false; _statusMessage = null;
        });
        return;
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка подключения:\n${e.runtimeType}: $e\n\nПроверь что backend запущен на $_backendUrl';
          _analyzing = false; _statusMessage = null;
        });
        return;
      }
    }

    setState(() {
      _errorMessage = 'Модель не успела прогреться. Попробуй ещё раз через 30 секунд.';
      _analyzing = false; _statusMessage = null;
    });
  }

  void _addToDiary() {
    if (_result == null) return;
    final predictions = _result!['all_predictions'] as List<dynamic>;
    final selected = predictions[_selectedIndex];
    final n = selected['nutrition'] as Map<String, dynamic>;
    final food = FoodItem(
      id: selected['label'],
      name: selected['label'],
      nameRu: n['nameRu'],
      calories: (n['calories'] as num).toDouble(),
      protein: (n['protein'] as num).toDouble(),
      fat: (n['fat'] as num).toDouble(),
      carbs: (n['carbs'] as num).toDouble(),
      category: 'recognized',
      emoji: n['emoji'],
    );
    final entry = MealEntry(food: food, grams: 100, time: DateTime.now());
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Распознавание еды'),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          if (_analyzing) _buildAnalyzingOverlay(),
          if (!_analyzing && _errorMessage != null) _buildErrorBanner(),
          if (!_analyzing && _result != null) _buildResultSheet(),
          if (!_analyzing && _result == null && _errorMessage == null) _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _imageBytes != null
          ? Opacity(
              opacity: 0.5,
              child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4CAF82), width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white30),
                          SizedBox(height: 12),
                          Text('Наведите камеру\nна блюдо', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildButtons() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF82),
                boxShadow: [BoxShadow(color: const Color(0xFF4CAF82).withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)],
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Сфотографировать', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white54),
            label: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4CAF82)),
            const SizedBox(height: 20),
            const Text('Анализирую блюдо...', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _statusMessage ?? 'ML модель обрабатывает изображение',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() { _errorMessage = null; _imageBytes = null; _statusMessage = null; }),
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF82), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSheet() {
    final predictions = _result!['all_predictions'] as List<dynamic>;
    final selected = predictions[_selectedIndex];
    final n = selected['nutrition'] as Map<String, dynamic>;
    final confidence = selected['confidence'];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),

            // Нутриенты выбранного блюда
            Row(
              children: [
                Text(n['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Распознано:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(n['nameRu'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                      Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: confidence >= 70 ? Colors.green[600] : Colors.orange[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Точность: $confidence%',
                            style: TextStyle(
                              color: confidence >= 70 ? Colors.green[600] : Colors.orange[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('Калории', '${n['calories']}', 'ккал', const Color(0xFF4CAF82)),
                  _stat('Белки', '${n['protein']}', 'г', const Color(0xFF5B8BF5)),
                  _stat('Жиры', '${n['fat']}', 'г', const Color(0xFFFF8C42)),
                  _stat('Углеводы', '${n['carbs']}', 'г', const Color(0xFFF5C842)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text('на 100 г продукта', style: TextStyle(color: Colors.grey, fontSize: 11)),

            // Варианты для выбора — только если точность < 90%
            if (predictions.length > 1 && (confidence as num) < 90) ...[
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Не то блюдо? Выбери правильный вариант:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              // Сортируем по убыванию точности, берём топ-3
              ...(() {
                final sorted = List<MapEntry<int, dynamic>>.from(predictions.asMap().entries.toList())
                  ..sort((a, b) => (b.value['confidence'] as num).compareTo(a.value['confidence'] as num));
                return sorted.take(3).map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final pn = p['nutrition'] as Map<String, dynamic>;
                  final isSelected = i == _selectedIndex;
                  final pct = p['confidence'] as num;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
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
                      child: Row(
                        children: [
                          Text(pn['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pn['nameRu'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                                color: isSelected ? const Color(0xFF2E7D5E) : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4CAF82) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, color: Color(0xFF4CAF82), size: 18),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList();
              })(),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() { _result = null; _imageBytes = null; _selectedIndex = 0; }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF82),
                      side: const BorderSide(color: Color(0xFF4CAF82)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Повторить'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _addToDiary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF82),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Добавить в дневник', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
