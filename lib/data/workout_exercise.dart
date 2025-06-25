import 'package:isar/isar.dart';
import 'exercise.dart';
import 'workout_set.dart';

part 'workout_exercise.g.dart';

@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  final exercise = IsarLink<Exercise>();

  List<WorkoutSet> sets = [];

  int order = 0;
  String? notes;
} 