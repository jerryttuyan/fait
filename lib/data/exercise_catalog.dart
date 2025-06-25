import 'exercise.dart';
import 'enums.dart'; // Assuming this file defines MuscleGroup, PushPullType, EquipmentType

final List<Exercise> defaultExercises = [
  // --- Chest Exercises ---
  Exercise()
    ..name = 'Barbell Bench Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Incline Barbell Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Decline Barbell Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Bench Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Incline Dumbbell Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Decline Dumbbell Press'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Dumbbell Fly'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Incline Dumbbell Fly'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Cable Crossover (High to Low)'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Cable Crossover (Low to High)'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Upper Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Pec Deck Fly Machine'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Chest Press Machine'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Push Up'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Dips (Chest Version)'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Lower Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Medicine Ball Chest Pass'
    ..muscleGroup = MuscleGroup.chest
    ..primaryMuscle = 'Pectoralis Major'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.other, // Assuming 'other' for medicine ball

  // --- Back Exercises ---
  Exercise()
    ..name = 'Deadlift'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Barbell Row'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'T-Bar Row'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Row'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Pull Up (Pronated Grip)'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Chin Up (Supinated Grip)'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Lat Pulldown (Wide Grip)'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Lat Pulldown (Close Grip)'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Seated Cable Row'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Rhomboids'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Single Arm Cable Row'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Latissimus Dorsi'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Face Pull'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Rear Deltoids'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Hyperextension (Back Extension)'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Good Mornings'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Erector Spinae'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Reverse Hyperextension'
    ..muscleGroup = MuscleGroup.back
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,

  // --- Legs Exercises ---
  Exercise()
    ..name = 'Barbell Back Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Barbell Front Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Leg Press'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Hack Squat Machine'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Bulgarian Split Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Dumbbell Lunges'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Goblet Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Romanian Deadlift (RDL)'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Leg Curl (Lying)'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Leg Curl (Seated)'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Glute Ham Raise (GHR)'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Hamstrings'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Glute Bridge'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Barbell Hip Thrust'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Cable Pull-Through'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gluteus Maximus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Standing Calf Raise Machine'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gastrocnemius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Seated Calf Raise Machine'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Soleus'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Donkey Calf Raise'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gastrocnemius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Adductor Machine'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Adductors'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Abductor Machine'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Gluteus Medius'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Pistol Squat'
    ..muscleGroup = MuscleGroup.legs
    ..primaryMuscle = 'Quadriceps'
    ..pushPullType = PushPullType.legs
    ..equipment = EquipmentType.bodyweight,

  // --- Shoulders Exercises ---
  Exercise()
    ..name = 'Barbell Overhead Press'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Anterior Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Shoulder Press'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Arnold Press'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Lateral Raise'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Lateral Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Front Raise'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Anterior Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Reverse Pec Deck Fly'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Rear Deltoid'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cable Lateral Raise'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Lateral Deltoid'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Upright Row'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Trapezius'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Shrugs'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Trapezius'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Kettlebell Press'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Handstand Push Up'
    ..muscleGroup = MuscleGroup.shoulders
    ..primaryMuscle = 'Deltoids'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,

  // --- Arms Exercises (Biceps) ---
  Exercise()
    ..name = 'Barbell Curl'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Dumbbell Curl (Standing)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Hammer Curl'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Brachialis'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Preacher Curl Machine'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cable Curl'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Concentration Curl'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Biceps Brachii'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Zottman Curl'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Brachialis'
    ..pushPullType = PushPullType.pull
    ..equipment = EquipmentType.dumbbell,

  // --- Arms Exercises (Triceps) ---
  Exercise()
    ..name = 'Close-Grip Bench Press'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Skullcrusher (Lying Triceps Extension)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Overhead Dumbbell Triceps Extension'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,
  Exercise()
    ..name = 'Triceps Pushdown (Rope Attachment)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Triceps Pushdown (Straight Bar)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Dips (Triceps Version)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Kickback (Dumbbell)'
    ..muscleGroup = MuscleGroup.arms
    ..primaryMuscle = 'Triceps Brachii'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.dumbbell,

  // --- Core Exercises ---
  Exercise()
    ..name = 'Plank'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Side Plank'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Russian Twist'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Crunches'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Bicycle Crunches'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Leg Raises (Lying)'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Lower Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Hanging Leg Raise'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Lower Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Cable Crunches'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.cable,
  Exercise()
    ..name = 'Ab Wheel Rollout'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Weighted Plank'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Rectus Abdominis'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.other, // E.g., plate on back
  Exercise()
    ..name = 'Landmine Twist'
    ..muscleGroup = MuscleGroup.core
    ..primaryMuscle = 'Obliques'
    ..pushPullType = PushPullType.push
    ..equipment = EquipmentType.barbell,

  // --- Full Body / Compound Exercises (already covered in other sections, but can be explicitly listed) ---
  Exercise()
    ..name = 'Kettlebell Swing'
    ..muscleGroup = MuscleGroup.fullBody
    ..primaryMuscle = 'Gluteus Maximus' // Primary focus, but full body
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.kettlebell,
  Exercise()
    ..name = 'Burpee'
    ..muscleGroup = MuscleGroup.fullBody
    ..primaryMuscle = 'Cardiovascular System' // More of a cardio/conditioning
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.bodyweight,
  Exercise()
    ..name = 'Clean and Jerk'
    ..muscleGroup = MuscleGroup.fullBody
    ..primaryMuscle = 'Multiple Muscle Groups'
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.barbell,
  Exercise()
    ..name = 'Snatch'
    ..muscleGroup = MuscleGroup.fullBody
    ..primaryMuscle = 'Multiple Muscle Groups'
    ..pushPullType = PushPullType.fullBody
    ..equipment = EquipmentType.barbell,

  // --- Cardio Exercises (basic examples) ---
  Exercise()
    ..name = 'Running (Treadmill)'
    ..muscleGroup = MuscleGroup.cardio
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Cycling (Stationary)'
    ..muscleGroup = MuscleGroup.cardio
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Rowing Machine'
    ..muscleGroup = MuscleGroup.cardio
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.machine,
  Exercise()
    ..name = 'Jump Rope'
    ..muscleGroup = MuscleGroup.cardio
    ..primaryMuscle = 'Cardiovascular System'
    ..pushPullType = PushPullType.cardio
    ..equipment = EquipmentType.other,
];
