// weight_tracking_page.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fait/data/weight_entry.dart'; // Import the Isar model
import 'package:fait/main.dart'; // Import to get the global 'isar' instance

class WeightTrackingPage extends StatefulWidget {
  const WeightTrackingPage({super.key});

  @override
  State<WeightTrackingPage> createState() => _WeightTrackingPageState();
}

class _WeightTrackingPageState extends State<WeightTrackingPage> {
  final _weightCtrl = TextEditingController();
  List<WeightEntry> _weightEntries = [];
  List<FlSpot> _chartSpots = [];

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  // Load data from the Isar database
  void _loadWeightData() async {
    final entries = await isar.weightEntrys.where().sortByDate().findAll();
    setState(() {
      _weightEntries = entries;
      // Convert WeightEntry objects to FlSpot objects for the chart
      _chartSpots = _weightEntries.asMap().entries.map((entry) {
        // Use the index for the x-axis and weight for the y-axis
        return FlSpot(entry.key.toDouble(), entry.value.weight);
      }).toList();
    });
  }

  // Add a new weight entry to the database
  void _addWeightEntry() async {
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) return;

    final newEntry = WeightEntry()
      ..weight = weight
      ..date = DateTime.now();

    // Use a write transaction to save the new entry
    await isar.writeTxn(() async {
      await isar.weightEntrys.put(newEntry);
    });

    _weightCtrl.clear();
    _loadWeightData(); // Reload the data to update the chart
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _weightCtrl,
            decoration: const InputDecoration(labelText: 'Enter current weight (lb)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addWeightEntry,
            child: const Text('Add Entry'),
          ),
          const SizedBox(height: 20),
          Text('Weight History', style: Theme.of(context).textTheme.titleLarge),
          Expanded(
            child: _chartSpots.isEmpty
                ? const Center(child: Text('Add a weight entry to see your progress.'))
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
                // ... (rest of your chart styling)
              ),
            ),
          ),
        ],
      ),
    );
  }
}