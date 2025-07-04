import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fait/data/enums.dart' as enums;
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/weight_entry.dart';
import 'package:fait/main.dart';
import 'package:fait/utils/weight_calculator.dart';
import 'package:fait/utils/calculators.dart';

class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  WeightManagementResult? _macrosResult;
  double? _bmi;
  double? _rmr;
  String? _errorMessage;
  List<WeightEntry> _weightEntries = [];
  List<FlSpot> _chartSpots = [];
  final _weightCtrl = TextEditingController();
  late final StreamSubscription<void> _dbChangeSubscription;

  static const double kgPerLb = 0.453592;
  static const double cmPerInch = 2.54;

  @override
  void initState() {
    super.initState();
    final userProfileStream = isar.userProfiles.watchLazy();
    final weightEntryStream = isar.weightEntrys.watchLazy();
    final mergedStream = StreamGroup.merge([userProfileStream, weightEntryStream]);
    _dbChangeSubscription = mergedStream.listen((_) {
      if (mounted) {
        _calculateAll();
        _loadWeightData();
      }
    });
    _calculateAll();
    _loadWeightData();
  }

  @override
  void dispose() {
    _dbChangeSubscription.cancel();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculateAll() async {
    setState(() {
      _macrosResult = null;
      _bmi = null;
      _rmr = null;
      _errorMessage = null;
    });
    final profile = await isar.userProfiles.get(1);
    final lastWeightEntry = await isar.weightEntrys.where().sortByDateDesc().findFirst();
    if (profile == null || profile.heightIn == null || profile.age == null) {
      setState(() {
        _errorMessage = "Please complete your profile information first.";
      });
      return;
    }
    if (lastWeightEntry == null) {
      setState(() {
        _errorMessage = "Please add a weight entry first.";
      });
      return;
    }
    // Macros calculation
    final weightKg = lastWeightEntry.weight * kgPerLb;
    final heightCm = profile.heightIn! * cmPerInch;
    final calcGender = profile.gender == enums.Gender.male ? Gender.male : Gender.female;
    final macrosResult = getWeightManagementPlan(
      weightKg: weightKg,
      heightCm: heightCm,
      age: profile.age!,
      gender: calcGender,
      activityLevel: ActivityLevel.values[profile.activityLevel.index],
      goal: WeightGoal.values[profile.weightGoal.index],
    );
    // BMI/RMR calculation
    final w = lastWeightEntry.weight;
    final h = profile.heightIn!;
    final a = profile.age!;
    final gender = profile.gender;
    setState(() {
      _macrosResult = macrosResult;
      _bmi = bmi(lb: w, inches: h);
      _rmr = rmr(lb: w, inches: h, age: a, gender: gender);
    });
  }

  void _loadWeightData() async {
    final entries = await isar.weightEntrys.where().sortByDate().findAll();
    setState(() {
      _weightEntries = entries;
      _chartSpots = _weightEntries.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.weight);
      }).toList();
    });
  }

  void _addWeightEntry() async {
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) return;
    final newEntry = WeightEntry()
      ..weight = weight
      ..date = DateTime.now();
    await isar.writeTxn(() async {
      await isar.weightEntrys.put(newEntry);
    });
    _weightCtrl.clear();
    _loadWeightData();
    _calculateAll();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          if (_errorMessage != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          if (_macrosResult != null && _errorMessage == null) ...[
            Text(
              'Daily Macros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildCompactMacrosRow(_macrosResult!),
            const SizedBox(height: 20),
          ],
          if (_bmi != null && _rmr != null && _errorMessage == null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'BMI',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                icon: Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showInfoDialog(
                                  context,
                                  'Body Mass Index (BMI)',
                                  'BMI is a measure of body fat based on height and weight. It helps assess if you\'re at a healthy weight for your height.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _bmi!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'RMR',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                icon: Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showInfoDialog(
                                  context,
                                  'Resting Metabolic Rate (RMR)',
                                  'RMR is the number of calories your body burns at rest to maintain basic life functions like breathing, circulation, and cell production.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Text(
                            '${_rmr!.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'kcal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage == null) ...[
            const SizedBox(height: 24),
            Text(
              'Weight Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 250,
                  child: _chartSpots.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Add weight entries to see your progress',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _chartSpots,
                                isCurved: true,
                                barWidth: 2.5,
                                color: Theme.of(context).colorScheme.primary,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                ),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Weight Entry',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        decoration: InputDecoration(
                          labelText: 'Current weight (lb)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addWeightEntry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMacrosRow(WeightManagementResult result) {
    final macros = [
      {
        'title': 'Calories',
        'value': result.macros.calories.round().toString(),
        'unit': 'kcal',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'Protein',
        'value': result.macros.protein.round().toString(),
        'unit': 'g',
        'icon': Icons.fitness_center,
        'color': Colors.red,
      },
      {
        'title': 'Carbs',
        'value': result.macros.carbs.round().toString(),
        'unit': 'g',
        'icon': Icons.grain,
        'color': Colors.green,
      },
      {
        'title': 'Fat',
        'value': result.macros.fat.round().toString(),
        'unit': 'g',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
    ];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(macros.length, (i) {
            final m = macros[i];
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(m['icon'] as IconData, size: 20, color: m['color'] as Color),
                  const SizedBox(height: 4),
                  Text(
                    m['value'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: m['color'] as Color,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    m['title'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    m['unit'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
} 