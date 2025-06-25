import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/user_profile.dart';
import 'data/weight_entry.dart';
import 'ui/pages/main_screen.dart';
import 'ui/pages/landing_page.dart';
import 'data/exercise.dart';
import 'data/workout.dart';
import 'data/workout_exercise.dart';
import 'data/workout_set.dart';
import 'data/exercise_catalog.dart';
import 'data/exercise_suggestions.dart';

// Testing flag - set to true to force onboarding, false for normal behavior
// When true: Always shows onboarding (will overwrite existing profile if one exists)
// When false: Checks for existing profile and skips onboarding if found
const bool FORCE_ONBOARDING = false;

// Optional: Clear existing profile data when forcing onboarding (for clean testing)
const bool CLEAR_PROFILE_ON_FORCE = true;

late Isar isar;

Future<void> clearAndReimportExercises() async {
  await isar.writeTxn(() async {
    await isar.exercises.clear();
    await isar.exercises.putAll(defaultExercises);
  });
  print('Exercises cleared and reimported.');
}

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
  // Check if exercises already exist in the database
  final existingExercises = await isar.exercises.where().findAll();
  
  // If no exercises exist, populate with default exercises
  if (existingExercises.isEmpty) {
    await isar.writeTxn(() async {
      await isar.exercises.putAll(defaultExercises);
    });
    print('Initialized exercise catalog with ${defaultExercises.length} exercises');
  } else {
    print('Exercise catalog already contains ${existingExercises.length} exercises');
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
        colorSchemeSeed: Colors.blue, // This is your main app's theme
      ),
      home: const AppStartupPage(),
    );
  }
}

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({super.key});

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    if (FORCE_ONBOARDING) {
      // For testing: always show onboarding
      if (CLEAR_PROFILE_ON_FORCE) {
        // Clear existing profile data for clean testing
        await isar.writeTxn(() async {
          await isar.userProfiles.clear();
          await isar.weightEntrys.clear();
        });
        print('Cleared existing profile data for testing');
      }
      
      setState(() {
        _hasProfile = false;
        _isLoading = false;
      });
      return;
    }
    
    // Normal behavior: check if profile exists
    final profile = await isar.userProfiles.get(1);
    setState(() {
      _hasProfile = profile != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _hasProfile ? const MainScreen() : const FitnessAppLandingPage();
  }
}