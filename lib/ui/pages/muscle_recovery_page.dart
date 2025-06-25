import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../main.dart';
import '../../data/enums.dart';
import '../../data/workout.dart';
import '../../utils/recovery_calculator.dart';

class MuscleRecoveryPage extends StatefulWidget {
  const MuscleRecoveryPage({Key? key}) : super(key: key);

  @override
  State<MuscleRecoveryPage> createState() => _MuscleRecoveryPageState();
}

class _MuscleRecoveryPageState extends State<MuscleRecoveryPage> {
  Future<Map<MuscleGroup, double>>? _recoveryFuture;

  @override
  void initState() {
    super.initState();
    _recoveryFuture = _fetchRecovery();
  }

  Future<Map<MuscleGroup, double>> _fetchRecovery() async {
    final workouts = await isar.completedWorkouts.where().sortByTimestampDesc().limit(20).findAll();
    return await RecoveryCalculator.calculateRecovery(workouts);
  }

  String _muscleGroupLabel(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.abs:
        return 'Abs';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.quadriceps:
        return 'Quads';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.lowerBack:
        return 'Lower Back';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Recovery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<MuscleGroup, double>>(
        future: _recoveryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final recovery = snapshot.data ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: MuscleGroup.values.map((group) {
              final percent = (recovery[group] ?? 1.0).clamp(0.0, 1.0);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _muscleGroupLabel(group),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${(percent * 100).round()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: percent > 0.7
                                  ? Colors.green
                                  : percent > 0.4
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent > 0.7
                              ? Colors.green
                              : percent > 0.4
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
} 