import 'package:isar/isar.dart';
import '../WorkoutData/workout.dart';

class ExerciseWeightSuggestion {
  final double suggestedWeight;
  final int suggestedSets;
  final double confidence; // 0.0 to 1.0
  final String reason;

  ExerciseWeightSuggestion({
    required this.suggestedWeight,
    required this.suggestedSets,
    required this.confidence,
    required this.reason,
  });
}

class ExerciseSuggestionService {
  static Future<ExerciseWeightSuggestion> getWeightSuggestion(
    Isar isar,
    String exerciseName,
    int targetReps,
  ) async {
    // Get recent history for this exercise from completed workouts (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final completedWorkouts = await isar.completedWorkouts
        .filter()
        .timestampGreaterThan(thirtyDaysAgo)
        .findAll();

    // Extract all sets for this exercise from recent workouts
    final exerciseSets = <CompletedSet>[];
    final setCounts = <int>[]; // Track how many sets were done each time

    for (final workout in completedWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          exerciseSets.addAll(exercise.sets);
          setCounts.add(exercise.sets.length);
        }
      }
    }

    if (exerciseSets.isEmpty) {
      return ExerciseWeightSuggestion(
        suggestedWeight: 0.0,
        suggestedSets: 3, // Default to 3 sets
        confidence: 0.0,
        reason: 'No previous history for this exercise',
      );
    }

    // Sort by most recent first
    exerciseSets.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    // Find the most recent weight for the same rep range (±2 reps)
    final similarReps = exerciseSets
        .where(
          (set) => (set.reps >= targetReps - 2) && (set.reps <= targetReps + 2),
        )
        .toList();

    // Calculate suggested sets (most common number of sets)
    final setFrequency = <int, int>{};
    for (final count in setCounts) {
      setFrequency[count] = (setFrequency[count] ?? 0) + 1;
    }
    final suggestedSets = setFrequency.isNotEmpty
        ? setFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 3; // Default to 3 sets

    if (similarReps.isNotEmpty) {
      // Use the most recent similar rep range
      final mostRecent = similarReps.first;
      return ExerciseWeightSuggestion(
        suggestedWeight: mostRecent.weight,
        suggestedSets: suggestedSets,
        confidence: 0.8,
        reason:
            'Based on recent ${mostRecent.reps} rep set (${suggestedSets} sets)',
      );
    }

    // If no similar rep range, find the most common weight
    final weightFrequency = <double, int>{};
    for (final set in exerciseSets) {
      weightFrequency[set.weight] = (weightFrequency[set.weight] ?? 0) + 1;
    }

    if (weightFrequency.isNotEmpty) {
      final mostCommonWeight = weightFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return ExerciseWeightSuggestion(
        suggestedWeight: mostCommonWeight,
        suggestedSets: suggestedSets,
        confidence: 0.6,
        reason: 'Based on most common weight used (${suggestedSets} sets)',
      );
    }

    // Fallback to most recent weight
    final mostRecent = exerciseSets.first;
    return ExerciseWeightSuggestion(
      suggestedWeight: mostRecent.weight,
      suggestedSets: suggestedSets,
      confidence: 0.4,
      reason: 'Based on most recent workout (${suggestedSets} sets)',
    );
  }

  static Future<List<CompletedSet>> getExerciseHistory(
    Isar isar,
    String exerciseName, {
    int limit = 10,
  }) async {
    final completedWorkouts = await isar.completedWorkouts
        .where()
        .sortByTimestampDesc()
        .findAll();

    final exerciseSets = <CompletedSet>[];
    for (final workout in completedWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          exerciseSets.addAll(exercise.sets);
          if (exerciseSets.length >= limit) break;
        }
      }
      if (exerciseSets.length >= limit) break;
    }

    // Sort by most recent first and limit
    exerciseSets.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return exerciseSets.take(limit).toList();
  }
}
