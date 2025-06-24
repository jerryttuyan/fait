import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fait/utils/calculators.dart';
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/weight_entry.dart';
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
            Column(
              children: [
                Text(
                  'Your Body Mass Index (BMI)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _bmi!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Resting Metabolic Rate (RMR)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _rmr!.toStringAsFixed(0) + ' kcal/day',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 32),
              ],
            ),
          const Divider(height: 40),
          Text('Weight Tracker', style: Theme.of(context).textTheme.titleLarge),
          TextField(
            controller: _weightCtrl,
            decoration: const InputDecoration(
              labelText: 'Enter current weight (lb)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addWeightEntry,
            child: const Text('Add Entry'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: _chartSpots.isEmpty
                ? const Center(
                    child: Text('Add a weight entry to see your progress.'),
                  )
                : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartSpots,
                          isCurved: true,
                          barWidth: 3,
                          color: Theme.of(context).colorScheme.primary,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Center(
            child: IconButton.filled(
              iconSize: 32,
              onPressed: () {
                _calculate();
                _loadWeightData();
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
