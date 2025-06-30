import 'package:isar/isar.dart';
import '../data/enums.dart';
import '../data/exercise.dart';
import '../data/workout.dart';
import '../data/exercise_suggestions.dart';
import '../data/user_profile.dart';
import '../data/weight_entry.dart';
import '../main.dart';
import 'recovery_calculator.dart';
import 'dart:math';

class WorkoutGenerator {
  // Configuration constants
  static const int maxExercisesPerWorkout = 8;
  static const int minExercisesPerWorkout = 4;
  static const int defaultSetsPerExercise = 3;
  static const int defaultReps = 10;
  
  // Recovery thresholds
  static const double minRecoveryThreshold = 0.3; // 30% recovery required
  static const double preferredRecoveryThreshold = 0.6; // 60% recovery preferred
  
  // Exercise selection weights
  static const double recoveryWeight = 0.4;
  static const double varietyWeight = 0.3;
  static const double progressionWeight = 0.3;

  // Progressive overload settings
  static const double weightIncreasePercent = 0.05; // 5% increase per set for progressive overload
  static const double weightDecreasePercent = 0.03; // 3% decrease for drop sets
  static const int maxProgressiveSets = 4; // Maximum sets with increasing weight

  /// Generates a workout based on recovery status and recent workout history
  static Future<GeneratedWorkout> generateWorkout({
    SplitType? preferredSplit,
    int targetExercises = 6,
    bool prioritizeRecovery = true,
  }) async {
    // Get user profile and current weight
    final userProfile = await isar.userProfiles.get(1);
    final currentWeight = await _getCurrentWeight();
    
    // Get recovery status
    final recentWorkouts = await isar.completedWorkouts
        .where()
        .sortByTimestampDesc()
        .limit(10)
        .findAll();
    final recovery = await RecoveryCalculator.calculateRecovery(recentWorkouts);
    
    // Determine optimal split type
    final splitType = preferredSplit ?? _determineOptimalSplit(recovery, recentWorkouts);
    
    // Get available exercises
    final allExercises = await isar.exercises.where().findAll();
    
    // Filter exercises based on split type and recovery
    final availableExercises = _filterExercisesForSplit(allExercises, splitType, recovery);
    
    // Score and select exercises
    final selectedExercises = await _selectExercises(
      availableExercises,
      targetExercises,
      recovery,
      recentWorkouts,
      prioritizeRecovery,
    );
    
    // Generate sets for each exercise with user profile consideration
    final exercisesWithSets = await _generateExerciseSets(
      selectedExercises,
      userProfile,
      currentWeight,
    );
    
    return GeneratedWorkout(
      splitType: splitType,
      exercises: exercisesWithSets,
      reasoning: _generateReasoning(splitType, recovery, selectedExercises, userProfile),
    );
  }

  /// Gets the user's current weight
  static Future<double?> _getCurrentWeight() async {
    final lastWeightEntry = await isar.weightEntrys.where().sortByDateDesc().findFirst();
    return lastWeightEntry?.weight;
  }

  /// Determines the optimal split type based on recovery and recent workouts
  static SplitType _determineOptimalSplit(
    Map<MuscleGroup, double> recovery,
    List<CompletedWorkout> recentWorkouts,
  ) {
    // Check recent workout history to avoid repeating the same split
    final recentSplits = <SplitType>[];
    for (final workout in recentWorkouts.take(3)) {
      // Try to infer split type from exercises
      final split = _inferSplitTypeFromExercises(workout.exercises);
      if (split != SplitType.other) {
        recentSplits.add(split);
      }
    }
    
    // Calculate recovery scores for each split type
    final splitScores = <SplitType, double>{};
    
    // Push day recovery (chest, shoulders, triceps)
    final pushRecovery = (recovery[MuscleGroup.chest] ?? 1.0) * 0.4 +
                        (recovery[MuscleGroup.shoulders] ?? 1.0) * 0.4 +
                        (recovery[MuscleGroup.triceps] ?? 1.0) * 0.2;
    splitScores[SplitType.push] = pushRecovery;
    
    // Pull day recovery (back, biceps)
    final pullRecovery = (recovery[MuscleGroup.back] ?? 1.0) * 0.7 +
                        (recovery[MuscleGroup.biceps] ?? 1.0) * 0.3;
    splitScores[SplitType.pull] = pullRecovery;
    
    // Legs day recovery (quads, hamstrings, glutes, lower back)
    final legsRecovery = (recovery[MuscleGroup.quadriceps] ?? 1.0) * 0.3 +
                        (recovery[MuscleGroup.hamstrings] ?? 1.0) * 0.3 +
                        (recovery[MuscleGroup.glutes] ?? 1.0) * 0.2 +
                        (recovery[MuscleGroup.lowerBack] ?? 1.0) * 0.2;
    splitScores[SplitType.legs] = legsRecovery;
    
    // Upper body recovery (push + pull muscles)
    final upperRecovery = (pushRecovery + pullRecovery) / 2;
    splitScores[SplitType.upper] = upperRecovery;
    
    // Lower body recovery (same as legs)
    splitScores[SplitType.lower] = legsRecovery;
    
    // Full body recovery (average of all major muscle groups)
    final fullBodyRecovery = recovery.values.reduce((a, b) => a + b) / recovery.length;
    splitScores[SplitType.fullBody] = fullBodyRecovery;
    
    // Penalize recently used splits
    for (final recentSplit in recentSplits) {
      if (splitScores.containsKey(recentSplit)) {
        splitScores[recentSplit] = splitScores[recentSplit]! * 0.5;
      }
    }
    
    // Return the split with the highest recovery score
    return splitScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Infers split type from completed exercises
  static SplitType _inferSplitTypeFromExercises(List<CompletedExercise> exercises) {
    final muscleGroups = <String>{};
    
    // For now, we'll use a simple heuristic based on exercise names
    // In a real implementation, you might want to cache exercise data
    for (final exercise in exercises) {
      final name = exercise.name.toLowerCase();
      
      // Push exercises
      if (name.contains('bench') || name.contains('press') || name.contains('push') ||
          name.contains('chest') || name.contains('shoulder') || name.contains('tricep')) {
        muscleGroups.add('chest');
        muscleGroups.add('shoulders');
        muscleGroups.add('triceps');
      }
      
      // Pull exercises
      if (name.contains('row') || name.contains('pull') || name.contains('back') ||
          name.contains('bicep') || name.contains('curl')) {
        muscleGroups.add('back');
        muscleGroups.add('biceps');
      }
      
      // Leg exercises
      if (name.contains('squat') || name.contains('deadlift') || name.contains('leg') ||
          name.contains('lunge') || name.contains('calf') || name.contains('glute')) {
        muscleGroups.add('quadriceps');
        muscleGroups.add('hamstrings');
        muscleGroups.add('glutes');
        muscleGroups.add('lowerBack');
      }
    }
    
    // Determine split type based on muscle groups
    final hasPush = muscleGroups.contains('chest') ||
                   muscleGroups.contains('shoulders') ||
                   muscleGroups.contains('triceps');
    final hasPull = muscleGroups.contains('back') ||
                   muscleGroups.contains('biceps');
    final hasLegs = muscleGroups.contains('quadriceps') ||
                   muscleGroups.contains('hamstrings') ||
                   muscleGroups.contains('glutes');
    
    if (hasPush && hasPull && hasLegs) return SplitType.fullBody;
    if (hasPush && hasPull) return SplitType.upper;
    if (hasLegs) return SplitType.lower;
    if (hasPush) return SplitType.push;
    if (hasPull) return SplitType.pull;
    
    return SplitType.other;
  }

  /// Filters exercises based on split type and recovery status
  static List<Exercise> _filterExercisesForSplit(
    List<Exercise> exercises,
    SplitType splitType,
    Map<MuscleGroup, double> recovery,
  ) {
    return exercises.where((exercise) {
      // Check if exercise matches the split type
      final matchesSplit = _exerciseMatchesSplit(exercise, splitType);
      if (!matchesSplit) return false;
      
      // Check if primary muscles are sufficiently recovered
      final primaryMuscleGroups = exercise.muscleGroups
          .where((name) => MuscleGroup.values.any((g) => g.name == name))
          .map((name) => MuscleGroup.values.firstWhere((g) => g.name == name))
          .toList();
      
      if (primaryMuscleGroups.isEmpty) return true;
      
      // Calculate average recovery for primary muscles
      final avgRecovery = primaryMuscleGroups
          .map((group) => recovery[group] ?? 1.0)
          .reduce((a, b) => a + b) / primaryMuscleGroups.length;
      
      return avgRecovery >= minRecoveryThreshold;
    }).toList();
  }

  /// Checks if an exercise matches the given split type
  static bool _exerciseMatchesSplit(Exercise exercise, SplitType splitType) {
    switch (splitType) {
      case SplitType.push:
        return exercise.pushPullType == PushPullType.push;
      case SplitType.pull:
        return exercise.pushPullType == PushPullType.pull;
      case SplitType.legs:
        return exercise.pushPullType == PushPullType.legs;
      case SplitType.upper:
        return exercise.pushPullType == PushPullType.push ||
               exercise.pushPullType == PushPullType.pull;
      case SplitType.lower:
        return exercise.pushPullType == PushPullType.legs;
      case SplitType.fullBody:
        return true; // All exercises are valid for full body
      case SplitType.other:
        return true;
    }
  }

  /// Selects exercises based on scoring criteria
  static Future<List<Exercise>> _selectExercises(
    List<Exercise> availableExercises,
    int targetCount,
    Map<MuscleGroup, double> recovery,
    List<CompletedWorkout> recentWorkouts,
    bool prioritizeRecovery,
  ) async {
    if (availableExercises.isEmpty) return [];
    
    // Score each exercise
    final scoredExercises = <_ScoredExercise>[];
    
    for (final exercise in availableExercises) {
      final score = await _calculateExerciseScore(
        exercise,
        recovery,
        recentWorkouts,
        prioritizeRecovery,
      );
      scoredExercises.add(_ScoredExercise(exercise, score));
    }
    
    // Sort by score (highest first)
    scoredExercises.sort((a, b) => b.score.compareTo(a.score));
    
    // Select top exercises, ensuring variety
    final selected = <Exercise>[];
    final usedMuscleGroups = <String>{};
    
    for (final scored in scoredExercises) {
      if (selected.length >= targetCount) break;
      
      // Check if this exercise adds variety
      final primaryMuscles = scored.exercise.muscleGroups.take(2).toSet();
      final newMuscles = primaryMuscles.difference(usedMuscleGroups);
      
      if (newMuscles.isNotEmpty || selected.length < targetCount ~/ 2) {
        selected.add(scored.exercise);
        usedMuscleGroups.addAll(primaryMuscles);
      }
    }
    
    return selected;
  }

  /// Calculates a score for an exercise based on various factors
  static Future<double> _calculateExerciseScore(
    Exercise exercise,
    Map<MuscleGroup, double> recovery,
    List<CompletedWorkout> recentWorkouts,
    bool prioritizeRecovery,
  ) async {
    double score = 0.0;
    
    // Recovery score
    final muscleGroups = exercise.muscleGroups
        .where((name) => MuscleGroup.values.any((g) => g.name == name))
        .map((name) => MuscleGroup.values.firstWhere((g) => g.name == name))
        .toList();
    
    if (muscleGroups.isNotEmpty) {
      final avgRecovery = muscleGroups
          .map((group) => recovery[group] ?? 1.0)
          .reduce((a, b) => a + b) / muscleGroups.length;
      score += avgRecovery * recoveryWeight;
    }
    
    // Variety score (prefer exercises not done recently)
    final recentExerciseNames = recentWorkouts
        .expand((w) => w.exercises)
        .map((e) => e.name)
        .toSet();
    
    if (!recentExerciseNames.contains(exercise.name)) {
      score += varietyWeight;
    }
    
    // Progression score (prefer exercises with recent history for progression)
    final hasHistory = await _hasRecentHistory(exercise.name, recentWorkouts);
    if (hasHistory) {
      score += progressionWeight;
    }
    
    return score;
  }

  /// Checks if an exercise has recent history for progression tracking
  static Future<bool> _hasRecentHistory(String exerciseName, List<CompletedWorkout> recentWorkouts) async {
    for (final workout in recentWorkouts.take(5)) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          return true;
        }
      }
    }
    return false;
  }

  /// Generates sets for each exercise with weight suggestions and progressive overload
  static Future<List<GeneratedExercise>> _generateExerciseSets(
    List<Exercise> exercises,
    UserProfile? userProfile,
    double? currentWeight,
  ) async {
    final generatedExercises = <GeneratedExercise>[];
    
    for (final exercise in exercises) {
      // Get weight suggestion with user profile consideration
      final suggestion = await ExerciseSuggestionService.getWeightSuggestion(
        isarInstance,
        exercise.name,
        defaultReps,
        userProfile: userProfile,
        currentWeight: currentWeight,
      );
      
      // Determine set scheme based on exercise type and user profile
      final setScheme = _determineSetScheme(exercise, userProfile, currentWeight);
      
      // Generate sets with progressive overload or other schemes
      final sets = _generateSetsWithScheme(
        baseWeight: suggestion.suggestedWeight,
        baseReps: defaultReps,
        scheme: setScheme,
        exerciseName: exercise.name,
      );
      
      generatedExercises.add(GeneratedExercise(
        exercise: exercise,
        sets: sets,
        suggestion: suggestion,
      ));
    }
    
    return generatedExercises;
  }

  /// Determines the appropriate set scheme based on exercise and user profile
  static SetScheme _determineSetScheme(Exercise exercise, UserProfile? userProfile, double? currentWeight) {
    // Default to standard sets
    if (userProfile == null) {
      return SetScheme.standard;
    }
    
    // For compound movements, use progressive overload
    if (_isCompoundExercise(exercise.name)) {
      return SetScheme.progressiveOverload;
    }
    
    // For isolation exercises, use standard or drop sets based on goal
    switch (userProfile.weightGoal) {
      case WeightGoal.weightGain:
        return SetScheme.dropSets; // More volume for muscle growth
      case WeightGoal.weightLoss:
        return SetScheme.superSets; // Higher intensity for fat loss
      case WeightGoal.maintenance:
        return SetScheme.standard;
    }
  }

  /// Checks if an exercise is a compound movement
  static bool _isCompoundExercise(String exerciseName) {
    final compoundKeywords = [
      'squat', 'deadlift', 'bench', 'press', 'row', 'pull-up', 'chin-up',
      'dip', 'lunge', 'clean', 'snatch', 'thruster'
    ];
    final name = exerciseName.toLowerCase();
    return compoundKeywords.any((keyword) => name.contains(keyword));
  }

  /// Generates sets based on the specified scheme
  static List<GeneratedSet> _generateSetsWithScheme({
    required double baseWeight,
    required int baseReps,
    required SetScheme scheme,
    required String exerciseName,
  }) {
    switch (scheme) {
      case SetScheme.standard:
        return List.generate(
          defaultSetsPerExercise,
          (index) => GeneratedSet(
            reps: baseReps,
            weight: ExerciseSuggestionService.roundToGymWeight(baseWeight, exerciseName),
            setNumber: index + 1,
          ),
        );
        
      case SetScheme.progressiveOverload:
        return List.generate(
          maxProgressiveSets,
          (index) {
            final weightIncrease = baseWeight * (weightIncreasePercent * index);
            final calculatedWeight = baseWeight + weightIncrease;
            return GeneratedSet(
              reps: baseReps - (index * 2), // Decrease reps as weight increases
              weight: ExerciseSuggestionService.roundToGymWeight(calculatedWeight, exerciseName),
              setNumber: index + 1,
            );
          },
        );
        
      case SetScheme.dropSets:
        return List.generate(
          defaultSetsPerExercise,
          (index) {
            if (index == 0) {
              return GeneratedSet(
                reps: baseReps,
                weight: ExerciseSuggestionService.roundToGymWeight(baseWeight, exerciseName),
                setNumber: index + 1,
              );
            } else {
              final weightDecrease = baseWeight * (weightDecreasePercent * index);
              final calculatedWeight = baseWeight - weightDecrease;
              return GeneratedSet(
                reps: baseReps + 2, // Increase reps as weight decreases
                weight: ExerciseSuggestionService.roundToGymWeight(calculatedWeight, exerciseName),
                setNumber: index + 1,
              );
            }
          },
        );
        
      case SetScheme.superSets:
        return List.generate(
          defaultSetsPerExercise,
          (index) => GeneratedSet(
            reps: baseReps + 2, // Higher reps for supersets
            weight: ExerciseSuggestionService.roundToGymWeight(baseWeight * 0.9, exerciseName), // Slightly lower weight for higher reps
            setNumber: index + 1,
          ),
        );
        
      case SetScheme.pyramid:
        final totalSets = 5;
        return List.generate(
          totalSets,
          (index) {
            if (index < totalSets ~/ 2) {
              // Ascending pyramid
              final weightIncrease = baseWeight * (weightIncreasePercent * index);
              final calculatedWeight = baseWeight + weightIncrease;
              return GeneratedSet(
                reps: baseReps - (index * 2),
                weight: ExerciseSuggestionService.roundToGymWeight(calculatedWeight, exerciseName),
                setNumber: index + 1,
              );
            } else {
              // Descending pyramid
              final weightDecrease = baseWeight * (weightDecreasePercent * (index - totalSets ~/ 2));
              final calculatedWeight = baseWeight - weightDecrease;
              return GeneratedSet(
                reps: baseReps + ((index - totalSets ~/ 2) * 2),
                weight: ExerciseSuggestionService.roundToGymWeight(calculatedWeight, exerciseName),
                setNumber: index + 1,
              );
            }
          },
        );
    }
  }

  /// Generates reasoning for the workout
  static String _generateReasoning(
    SplitType splitType,
    Map<MuscleGroup, double> recovery,
    List<Exercise> selectedExercises,
    UserProfile? userProfile,
  ) {
    final reasons = <String>[];
    
    // Split type reasoning
    reasons.add('Selected ${splitType.name} split based on recovery status.');
    
    // Recovery reasoning
    final lowRecoveryMuscles = recovery.entries
        .where((entry) => entry.value < preferredRecoveryThreshold)
        .map((entry) => entry.key.name)
        .toList();
    
    if (lowRecoveryMuscles.isNotEmpty) {
      reasons.add('Avoided ${lowRecoveryMuscles.join(', ')} due to low recovery.');
    }
    
    // User profile reasoning
    if (userProfile != null) {
      reasons.add('Tailored for ${userProfile.weightGoal.name} goal.');
      if (userProfile.activityLevel == ActivityLevel.veryActive || 
          userProfile.activityLevel == ActivityLevel.extraActive) {
        reasons.add('Higher volume for active lifestyle.');
      }
    }
    
    // Exercise selection reasoning
    reasons.add('Selected ${selectedExercises.length} exercises for optimal volume.');
    
    return reasons.join(' ');
  }
}

/// Enum for different set schemes
enum SetScheme {
  standard,        // Same weight and reps for all sets
  progressiveOverload, // Increasing weight, decreasing reps
  dropSets,       // Decreasing weight, increasing reps
  superSets,      // Higher reps, slightly lower weight
  pyramid,        // Ascending then descending weight
}

/// Helper class for scoring exercises
class _ScoredExercise {
  final Exercise exercise;
  final double score;
  
  _ScoredExercise(this.exercise, this.score);
}

/// Generated workout data structure
class GeneratedWorkout {
  final SplitType splitType;
  final List<GeneratedExercise> exercises;
  final String reasoning;
  
  GeneratedWorkout({
    required this.splitType,
    required this.exercises,
    required this.reasoning,
  });
}

/// Generated exercise with sets
class GeneratedExercise {
  final Exercise exercise;
  final List<GeneratedSet> sets;
  final ExerciseWeightSuggestion suggestion;
  
  GeneratedExercise({
    required this.exercise,
    required this.sets,
    required this.suggestion,
  });
}

/// Generated set with weight and reps
class GeneratedSet {
  final int reps;
  final double weight;
  final int setNumber;
  
  GeneratedSet({
    required this.reps,
    required this.weight,
    required this.setNumber,
  });
}

// Helper to get isar instance
Isar get isarInstance => isar; 