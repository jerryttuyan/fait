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

Future<void> _loadExercises() async {
  final existing = await isar.exercises.count();
  
  if (existing == 0) {
    // First time loading - insert all default exercises
    await isar.writeTxn(() async {
      await isar.exercises.putAll(defaultExercises);
    });
  } else {
    // Check for new exercises and add them
    final existingExercises = await isar.exercises.where().findAll();
    final existingNames = existingExercises.map((e) => e.name).toSet();
    
    final newExercises = defaultExercises.where((exercise) => 
      !existingNames.contains(exercise.name)
    ).toList();
    
    if (newExercises.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.exercises.putAll(newExercises);
      });
      print('Added ${newExercises.length} new exercises to the database');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fait',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}