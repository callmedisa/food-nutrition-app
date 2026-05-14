import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';

class StatsScreen extends StatefulWidget {
  final UserProfile? profile;
  const StatsScreen({super.key, this.profile});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<DateTime, double> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseService.getCaloriesPerDay(7);
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  List<MapEntry<DateTime, double>> get _sorted =>
    _data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  double get _avgCalories {
    final nonZero = _sorted.where((e) => e.value > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.fold(0.0, (s, e) => s + e.value) / nonZero.length;
  }

  int get _goalCalories => widget.profile?.calorieGoal ?? 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82)))
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryRow(),
                const SizedBox(height: 16),
                _buildChart(),
                const SizedBox(height: 16),
                _buildDaysList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryRow() {
    final avg = _avgCalories;
    final goal = _goalCalories;
    final daysLogged = _sorted.where((e) => e.value > 0).length;
    return Row(children: [
      Expanded(child: _statCard('Среднее', '${avg.toInt()} ккал',
          avg > goal ? const Color(0xFFE57373) : const Color(0xFF4CAF82), Icons.bar_chart)),
      const SizedBox(width: 8),
      Expanded(child: _statCard('Цель', '$goal ккал', const Color(0xFF5B8BF5), Icons.flag_outlined)),
      const SizedBox(width: 8),
      Expanded(child: _statCard('Дней\nзаписей', '$daysLogged / 7', const Color(0xFFFF8C42), Icons.calendar_today_outlined)),
    ]);
  }

  Widget _statCard(String label, String value, Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    ),
  );

  Widget _buildChart() {
    final sorted = _sorted;
    final maxY = sorted.fold<double>(_goalCalories.toDouble(), (m, e) => e.value > m ? e.value : m) * 1.15;
    final goalY = _goalCalories.toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text('Калории за 7 дней', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: goalY / 2,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: goalY / 2,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}к' : v.toInt().toString(),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                        final day = sorted[idx].key;
                        final isToday = _isToday(day);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('E', 'ru').format(day),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? const Color(0xFF4CAF82) : Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: goalY,
                    color: const Color(0xFF4CAF82).withOpacity(0.5),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: TextStyle(color: const Color(0xFF4CAF82), fontSize: 10, fontWeight: FontWeight.bold),
                      labelResolver: (_) => 'Цель',
                    ),
                  ),
                ]),
                barGroups: sorted.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cal = entry.value.value;
                  final isToday = _isToday(entry.value.key);
                  final overGoal = cal > goalY;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: cal == 0 ? 0.01 : cal,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        color: cal == 0
                          ? Colors.grey[200]
                          : overGoal
                            ? const Color(0xFFE57373)
                            : isToday
                              ? const Color(0xFF4CAF82)
                              : const Color(0xFF4CAF82).withOpacity(0.55),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const SizedBox(width: 8),
            _legendDot(const Color(0xFF4CAF82)), const SizedBox(width: 4),
            Text('В норме', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            const SizedBox(width: 12),
            _legendDot(const Color(0xFFE57373)), const SizedBox(width: 4),
            Text('Превышение', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            const SizedBox(width: 12),
            Container(width: 16, height: 2, color: const Color(0xFF4CAF82).withOpacity(0.5)),
            const SizedBox(width: 4),
            Text('Цель', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ]),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _buildDaysList() {
    final goal = _goalCalories;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('По дням', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._sorted.reversed.map((e) => _dayTile(e.key, e.value, goal)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dayTile(DateTime day, double cals, int goal) {
    final isToday = _isToday(day);
    final pct = cals == 0 ? 0.0 : (cals / goal).clamp(0.0, 1.0);
    final over = cals > goal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 72,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isToday ? 'Сегодня' : DateFormat('E, d MMM', 'ru').format(day),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: isToday ? const Color(0xFF4CAF82) : Colors.black87,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(
              cals == 0 ? Colors.grey[200]! : over ? const Color(0xFFE57373) : const Color(0xFF4CAF82),
            ),
          ),
        )),
        const SizedBox(width: 10),
        Text(
          cals == 0 ? '—' : '${cals.toInt()} ккал',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: over ? const Color(0xFFE57373) : Colors.black87,
          ),
        ),
      ]),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}
