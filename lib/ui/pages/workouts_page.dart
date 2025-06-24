import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../main.dart';
import '../../data/workout.dart';
import 'workout_builder_page.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({Key? key}) : super(key: key);

  Future<List<CompletedWorkout>> _fetchCompletedWorkouts() async {
    return await isar.completedWorkouts.where().sortByTimestampDesc().findAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: FutureBuilder<List<CompletedWorkout>>(
        future: _fetchCompletedWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Text('No recent workouts yet.'));
          }
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text('Workout on ${workout.timestamp.toLocal().toString().split(' ')[0]}'),
                subtitle: Text('${workout.exercises.length} exercises'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutSummaryPage(
                        duration: DateTime.now().difference(workout.timestamp),
                        completedWorkout: workout,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
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
                      (context as Element).reassemble(); // Quick way to refresh the list
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'main_fab',
        icon: const Icon(Icons.add),
        label: const Text('Create Workout'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WorkoutBuilderPage()),
          );
        },
      ),
    );
  }
} 