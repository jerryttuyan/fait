import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/user_profile.dart';
import 'data/weight_entry.dart';
import 'ui/pages/landing_page.dart'; // Import the new landing page
// import 'ui/pages/main_screen.dart'; // MainScreen is not the initial home anymore

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([
    WeightEntrySchema,
    UserProfileSchema,
  ], directory: dir.path);
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
      // Set the new FitnessAppLandingPage as the starting screen
      home: const FitnessAppLandingPage(),
    );
  }
}
