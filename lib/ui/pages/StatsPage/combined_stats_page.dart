import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fait/utils/calculators.dart';
import 'package:fait/data/ProfileData/user_profile.dart';
import 'package:fait/data/StatsData/weight_entry.dart';
import 'package:fait/main.dart';

class CombinedStatsPage extends StatefulWidget {
  const CombinedStatsPage({super.key});

  @override
  State<CombinedStatsPage> createState() => _CombinedStatsPageState();
}

class _CombinedStatsPageState extends State<CombinedStatsPage> {
  double? _bmi;
  double? _rmr;
  String? _errorMessage;
  List<WeightEntry> _weightEntries = [];
  List<FlSpot> _chartSpots = [];
  final _weightCtrl = TextEditingController();
  late final StreamSubscription<void> _dbChangeSubscription;

  @override
  void initState() {
    super.initState();
    final userProfileStream = isar.userProfiles.watchLazy();
    final weightEntryStream = isar.weightEntrys.watchLazy();
    final mergedStream = StreamGroup.merge([
      userProfileStream,
      weightEntryStream,
    ]);
    _dbChangeSubscription = mergedStream.listen((_) {
      if (mounted) {
        _calculate();
        _loadWeightData();
      }
    });
    _calculate();
    _loadWeightData();
  }

  @override
  void dispose() {
    _dbChangeSubscription.cancel();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() {
      _bmi = null;
      _rmr = null;
      _errorMessage = null;
    });
    final profile = await isar.userProfiles.get(1);
    final lastWeightEntry = await isar.weightEntrys
        .where()
        .sortByDateDesc()
        .findFirst();
    if (profile == null || profile.heightIn == null || profile.age == null) {
      setState(() {
        _errorMessage =
            "Please complete your height, gender, and birthday in the 'Profile' tab.";
      });
      return;
    }
    if (lastWeightEntry == null) {
      setState(() {
        _errorMessage =
            "Please add a weight entry in the 'Weight' section below.";
      });
      return;
    }
    final w = lastWeightEntry.weight;
    final h = profile.heightIn!;
    final a = profile.age!;
    final gender = profile.gender;
    setState(() {
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
    _calculate();
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
          if (_bmi != null && _rmr != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
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
                    // BMI Value
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _bmi!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.grey.shade300,
                    ),
                    // RMR Label
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'RMR',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
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
                    // RMR Value
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Text(
                            '${_rmr!.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          Text(
                            'kcal',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Weight Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 250,
                child: _chartSpots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add weight entries to see your progress',
                              style: TextStyle(
                                color: Colors.grey[600],
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
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
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
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
