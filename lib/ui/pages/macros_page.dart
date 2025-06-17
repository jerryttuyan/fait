import 'dart:async';
import 'package:async/async.dart';
import 'package:fait/data/enums.dart' as enums;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/weight_entry.dart';
import 'package:fait/main.dart';
import 'package:fait/utils/weight_calculator.dart'; // Import your main calculator logic

class MacrosPage extends StatefulWidget {
  const MacrosPage({super.key});

  @override
  State<MacrosPage> createState() => _MacrosPageState();
}

class _MacrosPageState extends State<MacrosPage> {
  WeightManagementResult? _result;
  String? _errorMessage;
  late final StreamSubscription<void> _dbChangeSubscription;

  // Conversion constants
  static const double kgPerLb = 0.453592;
  static const double cmPerInch = 2.54;

  @override
  void initState() {
    super.initState();
    final userProfileStream = isar.userProfiles.watchLazy();
    final weightEntryStream = isar.weightEntrys.watchLazy();
    final mergedStream = StreamGroup.merge([userProfileStream, weightEntryStream]);
    _dbChangeSubscription = mergedStream.listen((_) {
      if (mounted) _calculate();
    });
    _calculate();
  }

  @override
  void dispose() {
    _dbChangeSubscription.cancel();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() {
      _result = null;
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

    // Convert imperial units from our DB to metric for the calculator
    final weightKg = lastWeightEntry.weight * kgPerLb;
    final heightCm = profile.heightIn! * cmPerInch;

    // The calculator expects its own Gender enum, so we map it.
    final calcGender = profile.gender == enums.Gender.male ? Gender.male : Gender.female;

    final result = getWeightManagementPlan(
      weightKg: weightKg,
      heightCm: heightCm,
      age: profile.age!,
      gender: calcGender,
      activityLevel: ActivityLevel.values[profile.activityLevel.index],
      goal: WeightGoal.values[profile.weightGoal.index],
    );

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
        ),
      );
    }

    if (_result == null) {
      return const CircularProgressIndicator();
    }

    return ListView(
      children: [
        _buildMacroCard('Calories', _result!.macros.calories.round().toString(), 'kcal'),
        const SizedBox(height: 16),
        _buildMacroCard('Protein', _result!.macros.protein.round().toString(), 'grams'),
        const SizedBox(height: 16),
        _buildMacroCard('Carbs', _result!.macros.carbs.round().toString(), 'grams'),
        const SizedBox(height: 16),
        _buildMacroCard('Fat', _result!.macros.fat.round().toString(), 'grams'),
        const SizedBox(height: 32),
        Center(
          child: IconButton.filled(
            iconSize: 32,
            onPressed: _calculate,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(String title, String value, String unit) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displayMedium),
            Text(unit, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
