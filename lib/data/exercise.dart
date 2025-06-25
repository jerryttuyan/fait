import 'package:isar/isar.dart';
import 'enums.dart';
// export 'workout.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  late String name;

  late List<String> muscleGroups;

  late String primaryMuscle;

  @enumerated
  PushPullType pushPullType = PushPullType.other;

  @enumerated
  EquipmentType equipment = EquipmentType.other;

  String? description;
  String? imageUrl;

  @ignore
  List<MuscleGroup> get muscleGroupEnums =>
      muscleGroups.map((e) => MuscleGroup.values.firstWhere((g) => g.name == e)).toList();
  @ignore
  set muscleGroupEnums(List<MuscleGroup> groups) =>
      muscleGroups = groups.map((g) => g.name).toList();
} 