import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String? _location;
  String? _equipment;
  String? _activity;
  String? _fitnessLevel;
  String? _goal;
  String _result = '';
  List<String> _workoutTypes = [];
  List<String> _specificWorkouts = [];

  final Map<String, List<String>> allWorkouts = {
    "Cardio Machines": [
      "Treadmill",
      "Rowing Machine",
      "Elliptical",
      "Stair Climber",
    ],
    "HIIT": ["Burpees", "Jump Squats", "Mountain Climbers"],
    "Endurance Lifting": ["Light Deadlifts", "High-Rep Bench Press"],
    "Bodyweight Cardio": ["High Knees", "Jumping Jacks", "Fast Lunges"],
    "Calisthenics": ["Pushups", "Pullups", "Dips", "Plank"],
    "Heavy Lifting": ["Deadlift", "Squat", "Bench Press"],
    "Compound Movements": ["Barbell Rows", "I dont know"],
    "Resistance Bands": ["Band Squats", "Band Chest Press", "Glute Kickbacks"],
    "Bodyweight Strength": ["Wall Sit", "Plank", "Superman Hold"],
    "Core Training": ["Leg Raises", "Russian Twists", "Bicycle Crunches"],
    "Outdoor Cardio": ["Running", "Swimming", "Cycling"],
  };

  List<String> getWorkoutTypes(String goal, String equipment) {
    if (goal == "weight_loss") {
      if (equipment == "gym")
        return [
          "Cardio Machines",
          "Endurance Lifting",
          "HIIT",
          "Core Training",
        ];
      if (equipment == "home")
        return [
          "HIIT",
          "Bodyweight Cardio",
          "Calisthenics",
          "Core Training",
          "Outdoor Cardio",
        ];
      return [
        "HIIT",
        "Bodyweight Cardio",
        "Calisthenics",
        "Core Training",
        "Outdoor Cardio",
      ];
    } else if (goal == "gain_muscle") {
      if (equipment == "gym") return ["Heavy Lifting", "Compound Movements"];
      if (equipment == "home") return ["Resistance Bands", "Calisthenics"];
      return ["Bodyweight Strength", "Core Training"];
    } else {
      return ["Bodyweight Cardio", "Core Training"];
    }
  }

  List<String> getSpecificWorkouts(
    List<String> types,
    String fitnessLevel,
    String activity,
  ) {
    int maxExercises = 5;
    if (activity == "2") maxExercises = 7;
    if (activity == "3") maxExercises = 10;

    List<String> result = [];
    for (var type in types) {
      result.addAll(allWorkouts[type] ?? []);
    }

    if (fitnessLevel == "beginner") {
      return result.take(maxExercises).toList();
    } else if (fitnessLevel == "intermediate") {
      return result.take(maxExercises + 2).toList();
    } else {
      return result;
    }
  }

  String suggestSchedule(String activity, String goal) {
    String schedule = '';
    switch (activity) {
      case "1":
        schedule = "For 1-3 days: Focus on full-body and recovery.";
        break;
      case "2":
        schedule = "For 4-5 days: Try push/pull or upper/lower body splits.";
        break;
      case "3":
        schedule = "For 6–7 days: Mix strength, cardio, and mobility work.";
        break;
      default:
        schedule = "Default: Aim for 4–5 days based on your availability.";
    }
    if (goal == "weight_loss") {
      schedule += "\nInclude cardio at least 3x per week.";
    } else if (goal == "gain_muscle") {
      schedule += "\nFocus on progressive overload and rest days.";
    }
    return schedule;
  }

  void _generateWorkout() {
    String equipment = _equipment ?? 'none';
    if (_location == "gym") equipment = "gym";
    if (_location == "home" && equipment != "home") equipment = "none";
    _workoutTypes = getWorkoutTypes(_goal ?? '', equipment);
    _specificWorkouts = getSpecificWorkouts(
      _workoutTypes,
      _fitnessLevel ?? '',
      _activity ?? '',
    );
    String schedule = suggestSchedule(_activity ?? '', _goal ?? '');
    setState(() {
      _result =
          "Workout Types: ${_workoutTypes.join(', ')}\n\nWeekly Schedule: $schedule\n\nSample Exercises:\n- ${_specificWorkouts.join('\n- ')}";
    });
  }

  void resetSelections() {
    setState(() {
      _location = null;
      _equipment = null;
      _activity = null;
      _fitnessLevel = null;
      _goal = null;
      _result = '';
      _workoutTypes = [];
      _specificWorkouts = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Find Your Workout Routine',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _location,
            decoration: const InputDecoration(
              labelText: 'Where do you workout?',
            ),
            items: const [
              DropdownMenuItem(value: 'home', child: Text('Home')),
              DropdownMenuItem(value: 'gym', child: Text('Gym')),
            ],
            onChanged: (v) => setState(() {
              _location = v;
              _equipment = null;
            }),
          ),
          if (_location == 'home')
            DropdownButtonFormField<String>(
              value: _equipment,
              decoration: const InputDecoration(
                labelText: 'Do you have equipment at home?',
              ),
              items: const [
                DropdownMenuItem(value: 'home', child: Text('Yes')),
                DropdownMenuItem(value: 'none', child: Text('No')),
              ],
              onChanged: (v) => setState(() => _equipment = v),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _activity,
            decoration: const InputDecoration(
              labelText: 'How many days per week?',
            ),
            items: const [
              DropdownMenuItem(value: '1', child: Text('1-3')),
              DropdownMenuItem(value: '2', child: Text('4-5')),
              DropdownMenuItem(value: '3', child: Text('6-7')),
            ],
            onChanged: (v) => setState(() => _activity = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _fitnessLevel,
            decoration: const InputDecoration(labelText: 'Fitness Level'),
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
              DropdownMenuItem(
                value: 'intermediate',
                child: Text('Intermediate'),
              ),
              DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
            ],
            onChanged: (v) => setState(() => _fitnessLevel = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _goal,
            decoration: const InputDecoration(labelText: 'Goal'),
            items: const [
              DropdownMenuItem(
                value: 'weight_loss',
                child: Text('Weight Loss'),
              ),
              DropdownMenuItem(
                value: 'gain_muscle',
                child: Text('Gain Muscle'),
              ),
            ],
            onChanged: (v) => setState(() => _goal = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                (_location != null &&
                    (_location != 'home' || _equipment != null) &&
                    _activity != null &&
                    _fitnessLevel != null &&
                    _goal != null)
                ? _generateWorkout
                : null,
            child: const Text('Get Workout'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: resetSelections,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
          const SizedBox(height: 12),
          if (_result.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_result, style: const TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
