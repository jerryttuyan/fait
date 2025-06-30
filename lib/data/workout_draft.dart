class WorkoutSetDraft {
  int reps;
  double weight;
  WorkoutSetDraft({required this.reps, required this.weight});
}

class WorkoutExerciseDraft {
  final String exerciseName;
  List<WorkoutSetDraft> sets;
  WorkoutExerciseDraft(this.exerciseName, this.sets);

  String get setsSummary => sets.map((s) => '${s.reps} x ${s.weight} lbs').join(', ');
} 