import 'package:isar/isar.dart';

part 'workout_set.g.dart';

@embedded
class WorkoutSet {
  late int reps;
  late double weight;
  int? rir; // Reps in reserve (optional)
  int? durationSeconds; // For timed sets (optional)
  int? restSeconds; // Rest timer (optional)
} 