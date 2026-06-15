import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:food_nutrition_app/l10n/app_localizations.dart';
import '../../../../providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final statsAsync = ref.watch(statsNotifierProvider);
    final goalCalories = profile?.calorieGoal ?? 2000;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.statsTitle),
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          final sorted = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
          final nonZero = sorted.where((e) => e.value > 0).toList();
          final avg = nonZero.isEmpty ? 0.0
              : nonZero.fold(0.0, (s, e) => s + e.value) / nonZero.length;
          final daysLogged = nonZero.length;

          return RefreshIndicator(
            onRefresh: () => ref.read(statsNotifierProvider.notifier).reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                Row(children: [
                  Expanded(child: _StatCard(label: l.statsAverage, value: '${avg.toInt()} ${l.labelKcal}',
                      color: avg > goalCalories ? const Color(0xFFE57373) : const Color(0xFF4CAF82), icon: Icons.bar_chart)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatCard(label: l.statsGoal, value: '$goalCalories ${l.labelKcal}',
                      color: const Color(0xFF5B8BF5), icon: Icons.flag_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatCard(label: l.statsDaysLogged, value: '$daysLogged / 7',
                      color: const Color(0xFFFF8C42), icon: Icons.calendar_today_outlined)),
                ]),
                const SizedBox(height: 16),
                // Chart
                _CalorieChart(sorted: sorted, goalCalories: goalCalories, l: l),
                const SizedBox(height: 16),
                // Days list
                _DaysList(sorted: sorted, goalCalories: goalCalories, l: l),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
    ]),
  );
}

class _CalorieChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> sorted;
  final int goalCalories;
  final AppLocalizations l;

  const _CalorieChart({required this.sorted, required this.goalCalories, required this.l});

  @override
  Widget build(BuildContext context) {
    final maxY = sorted.fold<double>(goalCalories.toDouble(), (m, e) => e.value > m ? e.value : m) * 1.15;
    final goalY = goalCalories.toDouble();
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(l.statsChartTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            maxY: maxY,
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              horizontalInterval: goalY / 2,
              getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 42, interval: goalY / 2,
                getTitlesWidget: (v, _) => Text(
                  v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}к' : v.toInt().toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
              )),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('E', 'ru').format(sorted[idx].key),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday(sorted[idx].key) ? FontWeight.bold : FontWeight.normal,
                        color: isToday(sorted[idx].key) ? const Color(0xFF4CAF82) : Colors.grey[500],
                      ),
                    ),
                  );
                },
              )),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: goalY,
                color: const Color(0xFF4CAF82).withOpacity(0.5),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true, alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 4, bottom: 2),
                  style: const TextStyle(color: Color(0xFF4CAF82), fontSize: 10, fontWeight: FontWeight.bold),
                  labelResolver: (_) => l.statsGoal,
                ),
              ),
            ]),
            barGroups: sorted.asMap().entries.map((entry) {
              final cal = entry.value.value;
              final today = isToday(entry.value.key);
              final over = cal > goalY;
              return BarChartGroupData(x: entry.key, barRods: [
                BarChartRodData(
                  toY: cal == 0 ? 0.01 : cal,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  color: cal == 0 ? Colors.grey[200]
                      : over ? const Color(0xFFE57373)
                      : today ? const Color(0xFF4CAF82)
                      : const Color(0xFF4CAF82).withOpacity(0.55),
                ),
              ]);
            }).toList(),
          )),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const SizedBox(width: 8),
          _dot(const Color(0xFF4CAF82)), const SizedBox(width: 4),
          Text(l.statsOnTrack,  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(width: 12),
          _dot(const Color(0xFFE57373)), const SizedBox(width: 4),
          Text(l.statsOverGoal, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _dot(Color c) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _DaysList extends StatelessWidget {
  final List<MapEntry<DateTime, double>> sorted;
  final int goalCalories;
  final AppLocalizations l;

  const _DaysList({required this.sorted, required this.goalCalories, required this.l});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(l.statsByDay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...sorted.reversed.map((e) {
          final day  = e.key;
          final cals = e.value;
          final pct  = cals == 0 ? 0.0 : (cals / goalCalories).clamp(0.0, 1.0);
          final over = cals > goalCalories;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 72,
                child: Text(
                  isToday(day) ? l.statsToday : DateFormat('E, d MMM', 'ru').format(day),
                  style: TextStyle(
                    fontWeight: isToday(day) ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                    color: isToday(day) ? const Color(0xFF4CAF82) : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 8,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cals == 0 ? Colors.grey[200]! : over ? const Color(0xFFE57373) : const Color(0xFF4CAF82),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Text(
                cals == 0 ? '—' : '${cals.toInt()} ${l.labelKcal}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: over ? const Color(0xFFE57373) : null),
              ),
            ]),
          );
        }),
        const SizedBox(height: 8),
      ]),
    );
  }
}