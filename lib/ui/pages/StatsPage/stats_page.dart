import 'dart:async'; // Import the async library for StreamSubscription
import 'package:async/async.dart'; // Import for StreamGroup
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fait/utils/calculators.dart';
import 'package:fait/data/ProfileData/user_profile.dart';
import 'package:fait/data/StatsData/weight_entry.dart';
import 'package:fait/main.dart';

class BmiRmrPage extends StatefulWidget {
  const BmiRmrPage({super.key});
  @override
  State<BmiRmrPage> createState() => _BmiRmrPageState();
}

class _BmiRmrPageState extends State<BmiRmrPage> {
  double? _bmi;
  double? _rmr;
  String? _errorMessage;

  // We will use a StreamSubscription to manage the lifecycle of our listener
  late final StreamSubscription<void> _dbChangeSubscription;

  @override
  void initState() {
    super.initState();
    // Create a separate stream for each collection we want to watch.
    final userProfileStream = isar.userProfiles.watchLazy();
    final weightEntryStream = isar.weightEntrys.watchLazy();

    // Merge the streams into one. It will emit an event if either stream does.
    final mergedStream = StreamGroup.merge([
      userProfileStream,
      weightEntryStream,
    ]);

    // Listen to the merged stream and recalculate when data changes.
    _dbChangeSubscription = mergedStream.listen((_) {
      if (mounted) {
        // Ensure the widget is still in the tree
        _calculate();
      }
    });

    // Perform the initial calculation when the page loads.
    _calculate();
  }

  @override
  void dispose() {
    // It's crucial to cancel the subscription when the widget is disposed to prevent memory leaks.
    _dbChangeSubscription.cancel();
    super.dispose();
  }

  Future<void> _calculate() async {
    // Reset state before calculation
    setState(() {
      _bmi = null;
      _rmr = null;
      _errorMessage = null;
    });

    // Fetch all necessary data from the database
    final profile = await isar.userProfiles.get(1);
    final lastWeightEntry = await isar.weightEntrys
        .where()
        .sortByDateDesc()
        .findFirst();

    // --- Data Validation ---
    if (profile == null || profile.heightIn == null || profile.age == null) {
      setState(() {
        _errorMessage =
            "Please complete your height, gender, and birthday in the 'Profile' tab.";
      });
      return;
    }
    if (lastWeightEntry == null) {
      setState(() {
        _errorMessage = "Please add a weight entry in the 'Weight' tab.";
      });
      return;
    }

    // --- Perform Calculation ---
    final w = lastWeightEntry.weight;
    final h = profile.heightIn!;
    final a = profile.age!;
    final gender = profile.gender;

    setState(() {
      _bmi = bmi(lb: w, inches: h);
      _rmr = rmr(lb: w, inches: h, age: a, gender: gender);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If there's an error, show it
            if (_errorMessage != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),

            // If there are results, show them
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
                  const SizedBox(height: 32),
                  Text(
                    'Your Resting Metabolic Rate (RMR)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_rmr!.round()} kcal/day',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Based on your latest data from your profile and weight log.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

            const SizedBox(height: 40),
            // Add a refresh button for clarity
            IconButton.filled(
              iconSize: 32,
              onPressed: _calculate,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
