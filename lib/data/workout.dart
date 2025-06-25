import 'package:isar/isar.dart';
import 'enums.dart';
import 'workout_exercise.dart';

part 'workout.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  DateTime date = DateTime.now();
  String? name;

  @enumerated
  SplitType splitType = SplitType.other;

  final exercises = IsarLinks<WorkoutExercise>();

  String? notes;
}

@collection
class WorkoutTemplate {
  Id id = Isar.autoIncrement;
  late String name;
  late List<WorkoutExerciseTemplate> exercises;
}

@embedded
class WorkoutExerciseTemplate {
  late String name;
  late int sets;
  late int reps;
  late double weight;
}

@collection
class CompletedWorkout {
  Id id = Isar.autoIncrement;
  late DateTime timestamp;
  late List<CompletedExercise> exercises;
  int? durationSeconds; // Duration in seconds
}

@embedded
class CompletedExercise {
  late String name;
  late List<CompletedSet> sets;
}

@embedded
class CompletedSet {
  late int reps;
  late double weight;
  late DateTime loggedAt;
} 