import 'exercise.dart';
import 'enums.dart';

final List<Exercise> defaultExercises = [
  Exercise()
    ..name = 'Bench Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Deadlift'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Pull Up'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Shoulder Press'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
]; 