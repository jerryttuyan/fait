import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/user_profile.dart'; // Import the new profile schema
import 'data/weight_entry.dart';
import 'ui/pages/main_screen.dart';
import 'data/exercise.dart';
import 'data/workout.dart';
import 'data/workout_exercise.dart';
import 'data/workout_set.dart';
import 'data/exercise_catalog.dart';
import 'data/exercise_suggestions.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      WeightEntrySchema,
      UserProfileSchema,
      ExerciseSchema,
      WorkoutSchema,
      WorkoutExerciseSchema,
      WorkoutTemplateSchema,
      // WorkoutSet is embedded, no schema needed
      CompletedWorkoutSchema,
    ],
    directory: dir.path,
  );

  // Load or update exercises
  await _loadExercises();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fait',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // This is your main app's theme
      ),
      home: const MainScreen(),
    );
  }
}