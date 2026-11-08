import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/expression_evaluator.dart';
import '../theme/luxury_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TextEditingController _dataController =
      TextEditingController(text: '12, 15, 18, 22, 22, 28, 30, 35, 42, 50');

  // Combinatorics
  int _combN = 10;
  int _combR = 3;

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateStats(List<double> raw) {
    if (raw.isEmpty) return {};
    final list = List<double>.from(raw)..sort();
    final n = list.length;
    final sum = list.reduce((a, b) => a + b);
    final mean = sum / n;

    // Geometric mean (only if all positive)
    double? geoMean;
    if (list.every((v) => v > 0)) {
      final logSum = list.map((v) => math.log(v)).reduce((a, b) => a + b);
      geoMean = math.exp(logSum / n);
    }

    // Median
    double median;
    if (n % 2 == 1) {
      median = list[n ~/ 2];
    } else {
      median = (list[n ~/ 2 - 1] + list[n ~/ 2]) / 2.0;
    }

    // Mode
    final freq = <double, int>{};
    for (var x in list) {
      freq[x] = (freq[x] ?? 0) + 1;
    }
    int maxF = 0;
    for (var f in freq.values) {
      if (f > maxF) maxF = f;
    }
    List<double> modes = [];
    if (maxF > 1) {
      modes = freq.entries.where((e) => e.value == maxF).map((e) => e.key).toList();
    }

    // Variance & StdDev
    final sumSqDiff = list.map((x) => math.pow(x - mean, 2).toDouble()).reduce((a, b) => a + b);
    final popVar = sumSqDiff / n;
    final popStd = math.sqrt(popVar);
    final sampleVar = n > 1 ? sumSqDiff / (n - 1) : 0.0;
    final sampleStd = math.sqrt(sampleVar);

    // Quartiles
    final q1 = _percentile(list, 0.25);
    final q3 = _percentile(list, 0.75);
    final iqr = q3 - q1;

    return {
      'count': n,
      'sum': sum,
      'mean': mean,
      'geoMean': geoMean,
      'median': median,
      'modes': modes,
      'min': list.first,
      'max': list.last,
      'range': list.last - list.first,
      'popVar': popVar,
      'popStd': popStd,
      'sampleVar': sampleVar,
      'sampleStd': sampleStd,
      'q1': q1,
      'q3': q3,
      'iqr': iqr,
    };
  }

  double _percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0;
    if (sorted.length == 1) return sorted.first;
    final pos = (sorted.length - 1) * p;
    final low = pos.floor();
    final high = pos.ceil();
    final weight = pos - low;
    return sorted[low] * (1 - weight) + sorted[high] * weight;
  }

  String _format(double d) {
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    // Parse input
    final text = _dataController.text;
    final parsed = text
        .split(RegExp(r'[,\s]+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => double.tryParse(s.trim()))
        .whereType<double>()
        .toList();

    final stats = _calculateStats(parsed);

    final nPr = ExpressionEvaluator.permutations(_combN, _combR);
    final nCr = ExpressionEvaluator.combinations(_combN, _combR);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Data input container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LuxuryTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: LuxuryTheme.borderGlowing),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dataset Values (comma or space separated):',
                  style: TextStyle(
                    color: LuxuryTheme.goldWarm,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dataController,
                  maxLines: 2,
                  style: TextStyle(
                    color: LuxuryTheme.textBright,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. 10, 20, 25, 30, 45, 50',
                    hintStyle: TextStyle(color: LuxuryTheme.textSubtle),
                    filled: true,
                    fillColor: LuxuryTheme.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LuxuryTheme.borderMuted),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LuxuryTheme.emeraldPrimary),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Statistics Grid Summary
          if (stats.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuxuryTheme.emeraldPrimary, width: 1.2),
                boxShadow: [
                  BoxShadow(color: LuxuryTheme.emeraldSubtle, blurRadius: 14),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Sample Size (n)', '${stats['count']}', LuxuryTheme.goldPrimary),
                      _buildStatCard('Mean (μ)', _format(stats['mean']), LuxuryTheme.emeraldBright),
                      _buildStatCard('Median', _format(stats['median']), LuxuryTheme.emeraldPrimary),
                    ],
                  ),
                  Divider(color: LuxuryTheme.borderMuted, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                        'Sample Std Dev (s)',
                        _format(stats['sampleStd']),
                        LuxuryTheme.goldWarm,
                      ),
                      _buildStatCard(
                        'Population Std (σ)',
                        _format(stats['popStd']),
                        LuxuryTheme.goldWarm,
                      ),
                      _buildStatCard(
                        'Sample Variance (s²)',
                        _format(stats['sampleVar']),
                        LuxuryTheme.textBright,
                      ),
                    ],
                  ),
                  Divider(color: LuxuryTheme.borderMuted, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Min / Max', '${_format(stats['min'])} / ${_format(stats['max'])}', LuxuryTheme.textBright),
                      _buildStatCard('Range', _format(stats['range']), LuxuryTheme.textMuted),
                      _buildStatCard('IQR (Q3-Q1)', _format(stats['iqr']), LuxuryTheme.emeraldPrimary),
                    ],
                  ),
                  if ((stats['modes'] as List<double>).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Mode(s): ${(stats['modes'] as List<double>).map(_format).join(', ')}',
                      style: TextStyle(
                        color: LuxuryTheme.goldPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Combinatorics & Permutations Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LuxuryTheme.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LuxuryTheme.borderGlowing),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMBINATORICS CALCULATOR (nCr & nPr)',
                  style: TextStyle(
                    color: LuxuryTheme.goldWarm,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('n = ', style: TextStyle(color: LuxuryTheme.textBright, fontSize: 16)),
                          Text('$_combN', style: TextStyle(color: LuxuryTheme.emeraldBright, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Slider(
                        value: _combN.toDouble(),
                        min: 1,
                        max: 30,
                        activeColor: LuxuryTheme.emeraldPrimary,
                        inactiveColor: LuxuryTheme.borderMuted,
                        onChanged: (v) {
                          setState(() {
                            _combN = v.toInt();
                            if (_combR > _combN) _combR = _combN;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('r = ', style: TextStyle(color: LuxuryTheme.textBright, fontSize: 16)),
                          Text('$_combR', style: TextStyle(color: LuxuryTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Slider(
                        value: _combR.toDouble(),
                        min: 0,
                        max: _combN.toDouble(),
                        activeColor: LuxuryTheme.goldPrimary,
                        inactiveColor: LuxuryTheme.borderMuted,
                        onChanged: (v) => setState(() => _combR = v.toInt()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: LuxuryTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxuryTheme.emeraldPrimary),
                      ),
                      child: Column(
                        children: [
                          Text('Combinations C(n, r)', style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _format(nCr),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: LuxuryTheme.emeraldBright,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: LuxuryTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxuryTheme.goldWarm),
                      ),
                      child: Column(
                        children: [
                          Text('Permutations P(n, r)', style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _format(nPr),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: LuxuryTheme.goldPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
