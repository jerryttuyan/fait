import 'package:isar/isar.dart';
import 'enums.dart';
// export 'workout.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  MuscleGroup muscleGroup = MuscleGroup.other;

  late String primaryMuscle;

  @enumerated
  PushPullType pushPullType = PushPullType.other;

  @enumerated
  EquipmentType equipment = EquipmentType.other;

  String? description;
  String? imageUrl;
} 