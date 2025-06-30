import 'package:isar/isar.dart';
import 'workout.dart';
import 'user_profile.dart';
import 'weight_entry.dart';
import 'enums.dart';

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
    int targetReps, {
    UserProfile? userProfile,
    double? currentWeight,
  }) async {
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
    
    // If no history, use initial weight suggestion
    if (exerciseSets.isEmpty) {
      return _calculateInitialWeightSuggestion(exerciseName, userProfile, currentWeight);
    }
    
    // Calculate base suggestion from history
    final baseSuggestion = _calculateBaseSuggestion(exerciseSets, setCounts, targetReps);
    
    // Apply user profile adjustments
    final adjustedSuggestion = _applyUserProfileAdjustments(
      baseSuggestion,
      userProfile,
      currentWeight,
      exerciseName,
    );
    
    return adjustedSuggestion;
  }

  /// Calculates base weight suggestion from exercise history
  static ExerciseWeightSuggestion _calculateBaseSuggestion(
    List<CompletedSet> exerciseSets,
    List<int> setCounts,
    int targetReps,
  ) {
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
    final similarReps = exerciseSets.where((set) => 
      (set.reps >= targetReps - 2) && (set.reps <= targetReps + 2)
    ).toList();
    
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
        reason: 'Based on recent ${mostRecent.reps} rep set (${suggestedSets} sets)',
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

  /// Calculates initial weight suggestion for new users
  static ExerciseWeightSuggestion _calculateInitialWeightSuggestion(
    String exerciseName,
    UserProfile? userProfile,
    double? currentWeight,
  ) {
    // Default starting weights based on exercise type and user profile
    double baseWeight = _getBaseWeightForExercise(exerciseName);
    
    // Adjust based on user's body weight
    if (currentWeight != null) {
      baseWeight = _adjustWeightForBodyWeight(baseWeight, currentWeight, exerciseName);
    }
    
    // Adjust based on user profile
    if (userProfile != null) {
      baseWeight = _adjustWeightForUserProfile(baseWeight, userProfile);
    }
    
    // Round to realistic gym equipment weight
    baseWeight = roundToGymWeight(baseWeight, exerciseName);
    
    return ExerciseWeightSuggestion(
      suggestedWeight: baseWeight,
      suggestedSets: 3,
      confidence: 0.3, // Low confidence for initial suggestions
      reason: 'Initial suggestion based on exercise type and profile',
    );
  }

  /// Gets base weight for different exercise types
  static double _getBaseWeightForExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    // Compound movements (heavier weights)
    if (name.contains('squat') || name.contains('deadlift')) {
      return 135.0; // Barbell weight
    }
    if (name.contains('bench') || name.contains('press')) {
      return 95.0; // Barbell weight
    }
    if (name.contains('row') || name.contains('pull')) {
      return 65.0; // Barbell weight
    }
    
    // Isolation movements (lighter weights)
    if (name.contains('curl') || name.contains('extension')) {
      return 25.0; // Dumbbell weight
    }
    if (name.contains('raise') || name.contains('fly')) {
      return 15.0; // Dumbbell weight
    }
    if (name.contains('crunch') || name.contains('sit-up')) {
      return 0.0; // Bodyweight
    }
    
    // Machine exercises
    if (name.contains('machine') || name.contains('press')) {
      return 50.0; // Machine weight
    }
    
    // Default for unknown exercises
    return 30.0;
  }

  /// Adjusts weight based on user's body weight
  static double _adjustWeightForBodyWeight(double baseWeight, double bodyWeight, String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    // For compound movements, weight correlates more with body weight
    if (name.contains('squat') || name.contains('deadlift')) {
      return baseWeight * (bodyWeight / 150.0); // Normalize to 150lb person
    }
    if (name.contains('bench') || name.contains('press')) {
      return baseWeight * (bodyWeight / 150.0) * 0.7; // Upper body is weaker
    }
    if (name.contains('row') || name.contains('pull')) {
      return baseWeight * (bodyWeight / 150.0) * 0.6; // Back strength
    }
    
    // For isolation movements, less correlation with body weight
    if (name.contains('curl') || name.contains('extension')) {
      return baseWeight * (bodyWeight / 150.0) * 0.3;
    }
    if (name.contains('raise') || name.contains('fly')) {
      return baseWeight * (bodyWeight / 150.0) * 0.2;
    }
    
    return baseWeight;
  }

  /// Adjusts weight based on user profile
  static double _adjustWeightForUserProfile(double baseWeight, UserProfile userProfile) {
    // Adjust for activity level
    switch (userProfile.activityLevel) {
      case ActivityLevel.sedentary:
        baseWeight *= 0.7; // 30% reduction for sedentary
        break;
      case ActivityLevel.lightlyActive:
        baseWeight *= 0.85; // 15% reduction
        break;
      case ActivityLevel.moderatelyActive:
        // Keep as is
        break;
      case ActivityLevel.veryActive:
        baseWeight *= 1.15; // 15% increase
        break;
      case ActivityLevel.extraActive:
        baseWeight *= 1.25; // 25% increase
        break;
    }
    
    // Adjust for weight goal
    switch (userProfile.weightGoal) {
      case WeightGoal.weightLoss:
        baseWeight *= 0.9; // 10% reduction for weight loss
        break;
      case WeightGoal.weightGain:
        baseWeight *= 1.1; // 10% increase for muscle gain
        break;
      case WeightGoal.maintenance:
        // Keep as is
        break;
    }
    
    return baseWeight;
  }

  /// Applies user profile adjustments to the base suggestion
  static ExerciseWeightSuggestion _applyUserProfileAdjustments(
    ExerciseWeightSuggestion baseSuggestion,
    UserProfile? userProfile,
    double? currentWeight,
    String exerciseName,
  ) {
    if (userProfile == null) {
      return baseSuggestion;
    }

    double adjustedWeight = baseSuggestion.suggestedWeight;
    int adjustedSets = baseSuggestion.suggestedSets;
    String reason = baseSuggestion.reason;
    double confidence = baseSuggestion.confidence;

    // Apply weight goal adjustments
    switch (userProfile.weightGoal) {
      case WeightGoal.weightGain:
        // For muscle gain, slightly increase weight and sets
        adjustedWeight *= 1.02; // 2% increase
        adjustedSets = (adjustedSets + 1).clamp(3, 5);
        reason += ' (adjusted for muscle gain)';
        break;
      case WeightGoal.weightLoss:
        // For weight loss, maintain weight but increase reps/sets for higher volume
        adjustedSets = (adjustedSets + 1).clamp(3, 5);
        reason += ' (adjusted for weight loss - higher volume)';
        break;
      case WeightGoal.maintenance:
        // Keep as is
        break;
    }

    // Apply activity level adjustments
    switch (userProfile.activityLevel) {
      case ActivityLevel.veryActive:
      case ActivityLevel.extraActive:
        // Higher activity level can handle more volume
        adjustedSets = (adjustedSets + 1).clamp(3, 6);
        reason += ' (higher volume for active lifestyle)';
        break;
      case ActivityLevel.sedentary:
      case ActivityLevel.lightlyActive:
        // Lower activity level - reduce volume
        adjustedSets = (adjustedSets - 1).clamp(2, 4);
        adjustedWeight *= 0.98; // Slightly reduce weight
        reason += ' (reduced volume for lower activity)';
        break;
      case ActivityLevel.moderatelyActive:
        // Keep as is
        break;
    }

    // Apply bodyweight-based adjustments for bodyweight exercises
    if (_isBodyweightExercise(exerciseName) && currentWeight != null) {
      // For bodyweight exercises, weight is not applicable
      adjustedWeight = 0.0;
      reason += ' (bodyweight exercise)';
    }

    // Apply progressive overload if there's history
    if (baseSuggestion.confidence > 0.5) {
      adjustedWeight *= 1.01; // 1% progressive overload
      reason += ' (progressive overload applied)';
    }

    // Round to realistic gym equipment weight
    adjustedWeight = roundToGymWeight(adjustedWeight, exerciseName);

    return ExerciseWeightSuggestion(
      suggestedWeight: adjustedWeight,
      suggestedSets: adjustedSets,
      confidence: confidence,
      reason: reason,
    );
  }

  /// Checks if an exercise is a bodyweight exercise
  static bool _isBodyweightExercise(String exerciseName) {
    final bodyweightKeywords = [
      'push-up', 'pushup', 'pull-up', 'pullup', 'chin-up', 'chinup',
      'dip', 'plank', 'crunch', 'sit-up', 'situp', 'burpee', 'mountain climber',
      'jumping jack', 'squat', 'lunge', 'glute bridge', 'wall sit'
    ];
    final name = exerciseName.toLowerCase();
    return bodyweightKeywords.any((keyword) => name.contains(keyword));
  }

  /// Gets exercise history with enhanced filtering
  static Future<List<CompletedSet>> getExerciseHistory(
    Isar isar,
    String exerciseName, {
    int limit = 10,
    Duration? timeRange,
  }) async {
    List<CompletedWorkout> completedWorkouts;
    
    if (timeRange != null) {
      final cutoffDate = DateTime.now().subtract(timeRange);
      completedWorkouts = await isar.completedWorkouts
          .filter()
          .timestampGreaterThan(cutoffDate)
          .sortByTimestampDesc()
          .findAll();
    } else {
      completedWorkouts = await isar.completedWorkouts
          .where()
          .sortByTimestampDesc()
          .findAll();
    }
    
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

  /// Gets progressive overload suggestions for an exercise
  static Future<List<ExerciseWeightSuggestion>> getProgressiveOverloadSuggestions(
    Isar isar,
    String exerciseName,
    UserProfile? userProfile,
    double? currentWeight,
  ) async {
    final baseSuggestion = await getWeightSuggestion(
      isar,
      exerciseName,
      10, // Base reps
      userProfile: userProfile,
      currentWeight: currentWeight,
    );

    final suggestions = <ExerciseWeightSuggestion>[];
    
    // Generate progressive overload sets
    for (int i = 0; i < 4; i++) {
      final weightIncrease = baseSuggestion.suggestedWeight * (0.05 * i); // 5% increase per set
      final reps = 10 - (i * 2); // Decrease reps as weight increases
      
      suggestions.add(ExerciseWeightSuggestion(
        suggestedWeight: baseSuggestion.suggestedWeight + weightIncrease,
        suggestedSets: 1, // One set per weight
        confidence: baseSuggestion.confidence * 0.9, // Slightly lower confidence
        reason: 'Progressive overload set ${i + 1}: ${reps} reps at ${(baseSuggestion.suggestedWeight + weightIncrease).toStringAsFixed(1)} lbs',
      ));
    }

    return suggestions;
  }

  /// Rounds weight to realistic gym equipment increments
  static double roundToGymWeight(double weight, String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    // Barbell exercises (45lb bar + plates)
    if (name.contains('barbell') || name.contains('squat') || name.contains('deadlift') || 
        name.contains('bench') || name.contains('row') || name.contains('press')) {
      return _roundToBarbellWeight(weight);
    }
    
    // Dumbbell exercises
    if (name.contains('dumbbell') || name.contains('curl') || name.contains('extension') ||
        name.contains('raise') || name.contains('fly')) {
      return _roundToDumbbellWeight(weight);
    }
    
    // Machine exercises (usually 5lb increments)
    if (name.contains('machine')) {
      return _roundToMachineWeight(weight);
    }
    
    // Cable exercises (usually 5lb increments)
    if (name.contains('cable')) {
      return _roundToCableWeight(weight);
    }
    
    // Bodyweight exercises
    if (_isBodyweightExercise(exerciseName)) {
      return 0.0;
    }
    
    // Default to 5lb increments for unknown equipment
    return _roundToNearestIncrement(weight, 5.0);
  }

  /// Rounds to realistic barbell weight (45lb bar + standard plates)
  static double _roundToBarbellWeight(double weight) {
    if (weight <= 45) return 45; // Just the bar
    
    // Standard plate increments: 2.5, 5, 10, 25, 35, 45 lbs
    final availablePlates = [2.5, 5.0, 10.0, 25.0, 35.0, 45.0];
    final barWeight = 45.0;
    final remainingWeight = weight - barWeight;
    
    if (remainingWeight <= 0) return barWeight;
    
    // Find the closest combination of plates
    double bestWeight = barWeight;
    double bestDifference = remainingWeight;
    
    // Try different combinations of plates
    for (final plate1 in availablePlates) {
      final total1 = barWeight + (plate1 * 2); // Plates on both sides
      if ((total1 - weight).abs() < bestDifference) {
        bestWeight = total1;
        bestDifference = (total1 - weight).abs();
      }
      
      for (final plate2 in availablePlates) {
        final total2 = barWeight + (plate1 * 2) + (plate2 * 2);
        if ((total2 - weight).abs() < bestDifference) {
          bestWeight = total2;
          bestDifference = (total2 - weight).abs();
        }
        
        for (final plate3 in availablePlates) {
          final total3 = barWeight + (plate1 * 2) + (plate2 * 2) + (plate3 * 2);
          if ((total3 - weight).abs() < bestDifference) {
            bestWeight = total3;
            bestDifference = (total3 - weight).abs();
          }
        }
      }
    }
    
    return bestWeight;
  }

  /// Rounds to realistic dumbbell weight
  static double _roundToDumbbellWeight(double weight) {
    // Common dumbbell increments: 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100
    final dumbbellWeights = [
      5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0
    ];
    
    return _roundToNearest(weight, dumbbellWeights);
  }

  /// Rounds to machine weight (usually 5lb increments)
  static double _roundToMachineWeight(double weight) {
    return _roundToNearestIncrement(weight, 5.0);
  }

  /// Rounds to cable weight (usually 5lb increments)
  static double _roundToCableWeight(double weight) {
    return _roundToNearestIncrement(weight, 5.0);
  }

  /// Rounds to nearest value in a list
  static double _roundToNearest(double value, List<double> options) {
    double best = options.first;
    double bestDifference = (value - best).abs();
    
    for (final option in options) {
      final difference = (value - option).abs();
      if (difference < bestDifference) {
        best = option;
        bestDifference = difference;
      }
    }
    
    return best;
  }

  /// Rounds to nearest increment
  static double _roundToNearestIncrement(double value, double increment) {
    return (value / increment).round() * increment;
  }
} 