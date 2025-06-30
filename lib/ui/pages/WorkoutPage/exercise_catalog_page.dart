import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../data/ExcerciseData/exercise.dart';
import '../../../data/WorkoutData/enums.dart';
import '../../../main.dart';

class ExerciseCatalogPage extends StatelessWidget {
  const ExerciseCatalogPage({Key? key}) : super(key: key);

  Future<List<Exercise>> _fetchExercises() async {
    return await isar.exercises.where().findAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Catalog')),
      body: FutureBuilder<List<Exercise>>(
        future: _fetchExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }
          final exercises = snapshot.data!;
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return ListTile(
                title: Text(ex.name),
                subtitle: Text(
                  '${ex.muscleGroups.join(', ')} • ${ex.equipment.name}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
