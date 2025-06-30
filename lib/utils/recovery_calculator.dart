import '../data/WorkoutData/enums.dart';
import '../data/WorkoutData/workout.dart';
import '../data/ExcerciseData/exercise.dart';
import 'dart:math';
import 'package:isar/isar.dart';
import '../main.dart';

class RecoveryCalculator {
  // --- Tunable parameters ---
  static const double baseFatigue = 0.15; // Base fatigue multiplier
  static const double intensityThreshold = 0.7; // 70% of max
  static const double intensityMultiplier =
      1.5; // Fatigue multiplier for intense sets
  static const double referenceVolume =
      1500.0; // Reference volume for normalization
  static const double lowerBodyMultiplier =
      1.2; // Lower body fatigue multiplier
  static const double multiJointMultiplier =
      1.1; // Multi-joint fatigue multiplier
  static const double defaultMultiplier = 1.0; // Default fatigue multiplier
  static const int upperBodyRecoveryHours = 48;
  static const int lowerBodyRecoveryHours = 72;
  static const double minFatigue = 0.0;
  static const double maxFatigue = 1.0;

  // Exponential decay constant calculator
  static double _decayK(int recoveryHours) {
    // exp(-k * recoveryHours) = 0.05 (95% recovered at recoveryHours)
    return -log(0.05) / recoveryHours;
  }

  /// Returns a map of MuscleGroup to recovery percentage (0.0 to 1.0)
  static Future<Map<MuscleGroup, double>> calculateRecovery(
    List<CompletedWorkout> workouts,
  ) async {
    final now = DateTime.now();
    final Map<MuscleGroup, double> fatigue = {
      for (final group in MuscleGroup.values) group: 0.0,
    };

    for (final workout in workouts) {
      final hoursAgo = now.difference(workout.timestamp).inHours;
      for (final exercise in workout.exercises) {
        final muscleGroups = await _getMuscleGroupsForExercise(exercise.name);
        final maxWeight = await _getHeaviestSetWeight(exercise.name);
        final isLowerBody = _isLowerBody(muscleGroups);
        final isMultiJoint = _isMultiJoint(exercise.name);
        final recoveryHours = isLowerBody
            ? lowerBodyRecoveryHours
            : upperBodyRecoveryHours;
        final k = _decayK(recoveryHours);
        final decay = exp(-k * hoursAgo);
        double typeMultiplier = defaultMultiplier;
        if (isLowerBody) typeMultiplier *= lowerBodyMultiplier;
        if (isMultiJoint) typeMultiplier *= multiJointMultiplier;
        for (final set in exercise.sets) {
          final setVolume = set.reps * set.weight;
          double setFatigue =
              (setVolume / referenceVolume) * baseFatigue * typeMultiplier;
          if (maxWeight > 0 && set.weight >= intensityThreshold * maxWeight) {
            setFatigue *= intensityMultiplier;
          }
          // TODO: If RPE or proximity to failure is available, add a multiplier here
          setFatigue *= decay; // Apply exponential decay
          for (final group in muscleGroups) {
            fatigue[group] = min(maxFatigue, fatigue[group]! + setFatigue);
          }
        }
      }
    }
    // Recovery is 1.0 - fatigue
    return fatigue.map(
      (group, f) => MapEntry(group, (1.0 - f).clamp(0.0, 1.0)),
    );
  }

  static Future<List<MuscleGroup>> _getMuscleGroupsForExercise(
    String exerciseName,
  ) async {
    final exercise = await isar.exercises
        .filter()
        .nameEqualTo(exerciseName)
        .findFirst();
    if (exercise == null) return [];
    return exercise.muscleGroups
        .where((name) => MuscleGroup.values.any((g) => g.name == name))
        .map((name) => MuscleGroup.values.firstWhere((g) => g.name == name))
        .toList();
  }

  static Future<double> _getHeaviestSetWeight(String exerciseName) async {
    final completedWorkouts = await isar.completedWorkouts.where().findAll();
    double maxWeight = 0.0;
    for (final workout in completedWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          for (final set in exercise.sets) {
            if (set.weight > maxWeight) {
              maxWeight = set.weight;
            }
          }
        }
      }
    }
    return maxWeight;
  }

  // --- Helpers for exercise type ---
  static bool _isLowerBody(List<MuscleGroup> groups) {
    // Lower body muscle groups
    return groups.any(
      (g) => [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
        MuscleGroup.quadriceps,
        MuscleGroup.lowerBack,
      ].contains(g),
    );
  }

  static bool _isMultiJoint(String exerciseName) {
    // Simple heuristic: if exercise name contains common multi-joint terms
    final multiJointKeywords = [
      'squat',
      'deadlift',
      'press',
      'row',
      'pull',
      'clean',
      'snatch',
      'lunge',
      'bench',
      'dip',
      'pushup',
      'push-up',
      'thruster',
      'burpee',
    ];
    final lower = exerciseName.toLowerCase();
    return multiJointKeywords.any((kw) => lower.contains(kw));
  }
}
