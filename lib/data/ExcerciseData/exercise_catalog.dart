import 'exercise.dart';
import '../WorkoutData/enums.dart'; // Assuming this file defines MuscleGroup, PushPullType, EquipmentType

final List<Exercise> defaultExercises = [
  // --- Chest Exercises ---
  Exercise()
    ..name = 'Barbell Bench Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Incline Barbell Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.shoulders.name,
      MuscleGroup.triceps.name,
    ]
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Decline Barbell Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Bench Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Incline Dumbbell Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.shoulders.name,
      MuscleGroup.triceps.name,
    ]
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Decline Dumbbell Press'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Dumbbell Fly'
    ..muscleGroups = [MuscleGroup.chest.name]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Incline Dumbbell Fly'
    ..muscleGroups = [MuscleGroup.chest.name, MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Cable Crossover (High to Low)'
    ..muscleGroups = [MuscleGroup.chest.name]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Cable Crossover (Low to High)'
    ..muscleGroups = [MuscleGroup.chest.name, MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Pec Deck Fly Machine'
    ..muscleGroups = [MuscleGroup.chest.name]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Chest Press Machine'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Push Up'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Dips (Chest Version)'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.triceps.name,
      MuscleGroup.shoulders.name,
    ]
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Medicine Ball Chest Pass'
    ..muscleGroups = [MuscleGroup.chest.name, MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.other, // Assuming 'other' for medicine ball
  // --- Back Exercises ---
  Exercise()
    ..name = 'Deadlift'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Barbell Row'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'T-Bar Row'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Row'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Pull Up (Pronated Grip)'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Chin Up (Supinated Grip)'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Lat Pulldown (Wide Grip)'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Lat Pulldown (Close Grip)'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Seated Cable Row'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Rhomboids'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Single Arm Cable Row'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Face Pull'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Rear Deltoids'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Hyperextension (Back Extension)'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Good Mornings'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Reverse Hyperextension'
    ..muscleGroups = [MuscleGroup.back.name]
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,

  // --- Legs Exercises ---
  Exercise()
    ..name = 'Barbell Back Squat'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Barbell Front Squat'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Leg Press'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Hack Squat Machine'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Bulgarian Split Squat'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Dumbbell Lunges'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Goblet Squat'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Romanian Deadlift (RDL)'
    ..muscleGroups = [
      MuscleGroup.hamstrings.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Leg Curl (Lying)'
    ..muscleGroups = [
      MuscleGroup.hamstrings.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Leg Curl (Seated)'
    ..muscleGroups = [
      MuscleGroup.hamstrings.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Glute Ham Raise (GHR)'
    ..muscleGroups = [
      MuscleGroup.hamstrings.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Glute Bridge'
    ..muscleGroups = [MuscleGroup.glutes.name, MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Barbell Hip Thrust'
    ..muscleGroups = [MuscleGroup.glutes.name, MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Cable Pull-Through'
    ..muscleGroups = [MuscleGroup.glutes.name, MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Standing Calf Raise Machine'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Gastrocnemius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Seated Calf Raise Machine'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Soleus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Donkey Calf Raise'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Gastrocnemius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Adductor Machine'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Adductors'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Abductor Machine'
    ..muscleGroups = [MuscleGroup.glutes.name, MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Gluteus Medius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Pistol Squat'
    ..muscleGroups = [
      MuscleGroup.quadriceps.name,
      MuscleGroup.glutes.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,

  // --- Shoulders Exercises ---
  Exercise()
    ..name = 'Barbell Overhead Press'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Anterior Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Shoulder Press'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Arnold Press'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Lateral Raise'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Lateral Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Front Raise'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Anterior Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Reverse Pec Deck Fly'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Rear Deltoid'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cable Lateral Raise'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Lateral Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Upright Row'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Trapezius'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Shrugs'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Trapezius'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Kettlebell Press'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Handstand Push Up'
    ..muscleGroups = [MuscleGroup.shoulders.name]
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,

  // --- Arms Exercises (Biceps) ---
  Exercise()
    ..name = 'Barbell Curl'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Curl (Standing)'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Hammer Curl'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Brachialis'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Preacher Curl Machine'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cable Curl'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Concentration Curl'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Zottman Curl'
    ..muscleGroups = [MuscleGroup.biceps.name]
    ..primaryMuscle = 'Brachialis'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,

  // --- Arms Exercises (Triceps) ---
  Exercise()
    ..name = 'Close-Grip Bench Press'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Skullcrusher (Lying Triceps Extension)'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Overhead Dumbbell Triceps Extension'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Triceps Pushdown (Rope Attachment)'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Triceps Pushdown (Straight Bar)'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Dips (Triceps Version)'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Kickback (Dumbbell)'
    ..muscleGroups = [MuscleGroup.triceps.name]
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,

  // --- Core Exercises ---
  Exercise()
    ..name = 'Plank'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Side Plank'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Russian Twist'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Crunches'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Bicycle Crunches'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Leg Raises (Lying)'
    ..muscleGroups = [MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Lower Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Hanging Leg Raise'
    ..muscleGroups = [MuscleGroup.lowerBack.name]
    ..primaryMuscle = 'Lower Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Cable Crunches'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Ab Wheel Rollout'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Weighted Plank'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.other, // E.g., plate on back
  Exercise()
    ..name = 'Landmine Twist'
    ..muscleGroups = [MuscleGroup.abs.name]
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,

  // --- Full Body / Compound Exercises (already covered in other sections, but can be explicitly listed) ---
  Exercise()
    ..name = 'Kettlebell Swing'
    ..muscleGroups = [MuscleGroup.glutes.name, MuscleGroup.lowerBack.name]
    ..primaryMuscle =
        'Gluteus Maximus' // Primary focus, but full body
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Burpee'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle =
        'Cardiovascular System' // More of a cardio/conditioning
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Clean and Jerk'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.back.name,
      MuscleGroup.shoulders.name,
      MuscleGroup.glutes.name,
      MuscleGroup.hamstrings.name,
      MuscleGroup.quadriceps.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Multiple Muscle Groups'
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Snatch'
    ..muscleGroups = [
      MuscleGroup.chest.name,
      MuscleGroup.back.name,
      MuscleGroup.shoulders.name,
      MuscleGroup.glutes.name,
      MuscleGroup.hamstrings.name,
      MuscleGroup.quadriceps.name,
      MuscleGroup.lowerBack.name,
    ]
    ..primaryMuscle = 'Multiple Muscle Groups'
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.barbell,

  // --- Cardio Exercises (basic examples) ---
  Exercise()
    ..name = 'Running (Treadmill)'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cycling (Stationary)'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Rowing Machine'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Jump Rope'
    ..muscleGroups = [MuscleGroup.cardio.name]
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.other,
];
