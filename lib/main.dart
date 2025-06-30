import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'data/ProfileData/user_profile.dart';
import 'data/StatsData/weight_entry.dart';
import 'ui/pages/MainPage/main_page.dart';
import 'ui/pages/MainPage/landing_page.dart';
import 'ui/pages/MainPage/login_page.dart';
import 'ui/pages/MainPage/profile_info_page.dart';
import 'data/ExcerciseData/exercise.dart';
import 'data/WorkoutData/workout.dart';
import 'data/WorkoutData/workout_exercise.dart';
import 'data/WorkoutData/workout_set.dart';
import 'data/ExcerciseData/exercise_catalog.dart';
import 'data/ExcerciseData/exercise_suggestions.dart';
import 'utils/app_settings.dart';

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
  isar = await Isar.open([
    WeightEntrySchema,
    UserProfileSchema,
    ExerciseSchema,
    WorkoutSchema,
    WorkoutExerciseSchema,
    WorkoutTemplateSchema,
    // WorkoutSet is embedded, no schema needed
    CompletedWorkoutSchema,
  ], directory: dir.path);

  // Load or update exercises
  await _loadExercises();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const MyApp(),
    ),
  );
}

Future<void> _loadExercises() async {
  // Check if exercises already exist in the database
  final existingExercises = await isar.exercises.where().findAll();

  // If no exercises exist, populate with default exercises
  if (existingExercises.isEmpty) {
    await isar.writeTxn(() async {
      await isar.exercises.putAll(defaultExercises);
    });
    print(
      'Initialized exercise catalog with ${defaultExercises.length} exercises',
    );
  } else {
    print(
      'Exercise catalog already contains ${existingExercises.length} exercises',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        ThemeMode themeMode;
        switch (settings.themeMode) {
          case AppThemeMode.light:
            themeMode = ThemeMode.light;
            break;
          case AppThemeMode.dark:
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }
        return MaterialApp(
          title: 'Fait',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          home: const AppStartupPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/profile_info': (context) {
              final username =
                  ModalRoute.of(context)?.settings.arguments as String? ?? '';
              return ProfileInfoPage(username: username);
            },
            '/main': (context) => const MainScreen(),
          },
        );
      },
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _hasProfile ? const MainScreen() : const FitnessAppLandingPage();
  }
}
