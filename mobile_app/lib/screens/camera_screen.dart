import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/food_database.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  bool _analyzing = false;
  FoodItem? _detected;
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

  Future<void> _simulateAnalysis() async {
    setState(() { _analyzing = true; _detected = null; });
    await Future.delayed(const Duration(seconds: 2));
    // Имитация распознавания — выбираем случайный продукт
    final items = FoodDatabase.items;
    final random = items[DateTime.now().millisecond % items.length];
    setState(() { _analyzing = false; _detected = random; });
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
          _buildCameraPlaceholder(),
          if (_analyzing) _buildAnalyzingOverlay(),
          if (_detected != null && !_analyzing) _buildResultSheet(),
          if (!_analyzing && _detected == null) _buildScanButton(),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
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
      child: Column(
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
          const SizedBox(height: 40),
          _buildCornerMarkers(),
        ],
      ),
    );
  }

  Widget _buildCornerMarkers() {
    return const SizedBox(
      width: 260,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.crop_free, color: Color(0xFF4CAF82), size: 28),
          Icon(Icons.crop_free, color: Color(0xFF4CAF82), size: 28),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          GestureDetector(
            onTap: _simulateAnalysis,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF82),
                boxShadow: [BoxShadow(color: const Color(0xFF4CAF82).withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
              ),
              child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Нажмите для анализа', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _simulateAnalysis,
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF82)),
            SizedBox(height: 20),
            Text('Анализирую блюдо...', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text('ML модель обрабатывает изображение', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSheet() {
    final f = _detected!;
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(f.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Распознано:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(f.nameRu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('Точность: 94%', style: TextStyle(color: Colors.green[600], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resultStat('Калории', '${f.calories.toInt()}', 'ккал', const Color(0xFF4CAF82)),
                  _resultStat('Белки', '${f.protein}', 'г', const Color(0xFF5B8BF5)),
                  _resultStat('Жиры', '${f.fat}', 'г', const Color(0xFFFF8C42)),
                  _resultStat('Углеводы', '${f.carbs}', 'г', const Color(0xFFF5C842)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('на 100 г продукта', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _detected = null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF82),
                      side: const BorderSide(color: Color(0xFF4CAF82)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Повторить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${f.nameRu} добавлено в дневник'), backgroundColor: const Color(0xFF4CAF82)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF82),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Добавить в дневник', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String label, String value, String unit, Color color) {
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
