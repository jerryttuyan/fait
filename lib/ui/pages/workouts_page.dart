import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../main.dart';
import '../../data/workout.dart';
import '../../data/exercise.dart';
import 'workout_builder_page.dart';
import 'muscle_recovery_page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({Key? key}) : super(key: key);

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  Future<List<CompletedWorkout>>? _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
  }

  void _refreshWorkouts() {
    setState(() {
      _workoutsFuture = _fetchCompletedWorkouts();
    });
  }

  Future<List<CompletedWorkout>> _fetchCompletedWorkouts() async {
    return await isar.completedWorkouts.where().sortByTimestampDesc().findAll();
  }

  // Group workouts by date
  Map<DateTime, List<CompletedWorkout>> _groupWorkoutsByDate(List<CompletedWorkout> workouts) {
    final grouped = <DateTime, List<CompletedWorkout>>{};
    for (final workout in workouts) {
      final date = DateTime(workout.timestamp.year, workout.timestamp.month, workout.timestamp.day);
      grouped.putIfAbsent(date, () => []).add(workout);
    }
    return grouped;
  }

  // Calculate total volume for a workout
  double _calculateVolume(CompletedWorkout workout) {
    double totalVolume = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        totalVolume += set.reps * set.weight;
      }
    }
    return totalVolume;
  }

  // Get muscles worked for a workout
  Future<Set<String>> _getMusclesWorked(CompletedWorkout workout) async {
    final muscleGroups = <String>{};
    try {
      for (final ex in workout.exercises) {
        final exercise = await isar.exercises.filter().nameEqualTo(ex.name).findFirst();
        if (exercise != null) {
          muscleGroups.addAll(exercise.muscleGroups);
        }
      }
    } catch (e) {
      print('Error looking up exercise: $e');
    }
    return muscleGroups;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final workoutDate = DateTime(date.year, date.month, date.day);
    
    if (workoutDate == today) {
      return 'Today';
    } else if (workoutDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '~30 min';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.self_improvement),
            tooltip: 'Muscle Recovery',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MuscleRecoveryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CompletedWorkout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your first workout to see it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedWorkouts = _groupWorkoutsByDate(workouts);
          final sortedDates = groupedWorkouts.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedDates.length,
            itemBuilder: (context, dateIndex) {
              final date = sortedDates[dateIndex];
              final dayWorkouts = groupedWorkouts[date]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _formatDate(date),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dayWorkouts.length} workout${dayWorkouts.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Workouts for this day
                  ...dayWorkouts.map((workout) => _buildWorkoutCard(workout)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'main_fab',
        icon: const Icon(Icons.add),
        label: const Text('Create Workout'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WorkoutBuilderPage()),
          );
          _refreshWorkouts();
        },
      ),
    );
  }

  Widget _buildWorkoutCard(CompletedWorkout workout) {
    final volume = _calculateVolume(workout);
    final exerciseCount = workout.exercises.length;
    final duration = _formatDuration(workout.durationSeconds);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutSummaryPage(
                duration: Duration(seconds: workout.durationSeconds ?? 1800),
                completedWorkout: workout,
              ),
            ),
          );
          _refreshWorkouts();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with time and options
              Row(
                children: [
                  Text(
                    _formatTime(workout.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<Set<String>>(
                    future: _getMusclesWorked(workout),
                    builder: (context, snapshot) {
                      final muscles = snapshot.data ?? {};
                      return Text(
                        muscles.isEmpty ? 'Various' : muscles.join(', '),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Workout'),
                            content: const Text('Are you sure you want to delete this workout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await isar.writeTxn(() async {
                            await isar.completedWorkouts.delete(workout.id);
                          });
                          _refreshWorkouts();
                        }
                      } else if (value == 'save_preset') {
                        await _saveWorkoutAsPreset(workout);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'save_preset',
                        child: Row(
                          children: [
                            Icon(Icons.save, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Save as Preset', style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Exercises',
                      '$exerciseCount',
                      Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Volume',
                      '${volume.toStringAsFixed(0)} lbs',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Duration',
                      duration,
                      Icons.timer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _saveWorkoutAsPreset(CompletedWorkout workout) async {
    // Get muscle groups for the preset name
    final muscles = await _getMusclesWorked(workout);
    final muscleString = muscles.isEmpty ? 'Workout' : muscles.join(', ');
    final defaultName = '$muscleString - ${workout.exercises.length} exercises';
    
    final nameController = TextEditingController(text: defaultName);
    
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Workout Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a name for this workout preset:'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                border: OutlineInputBorder(),
              ),
              controller: nameController,
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      // Create workout template from completed workout
      final template = WorkoutTemplate()
        ..name = name.trim()
        ..exercises = workout.exercises.map((ex) {
          // Use the first set as the template (most common approach)
          final firstSet = ex.sets.isNotEmpty ? ex.sets.first : CompletedSet()
            ..reps = 10
            ..weight = 0;
          
          return WorkoutExerciseTemplate()
            ..name = ex.name
            ..sets = ex.sets.length
            ..reps = firstSet.reps
            ..weight = firstSet.weight;
        }).toList();

      await isar.writeTxn(() async {
        await isar.workoutTemplates.put(template);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout preset "$name" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
} 