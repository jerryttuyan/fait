import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../data/enums.dart';
import '../../data/exercise.dart';
import '../../data/workout.dart';
import '../../main.dart';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';

class WorkoutBuilderPage extends StatefulWidget {
  const WorkoutBuilderPage({Key? key}) : super(key: key);

  @override
  State<WorkoutBuilderPage> createState() => _WorkoutBuilderPageState();
}

class _WorkoutBuilderPageState extends State<WorkoutBuilderPage> {
  final List<_WorkoutExerciseDraft> _exercises = [];
  final DateTime _workoutDate = DateTime.now();

  void _addExercise() async {
    final result = await showModalBottomSheet<_ExercisePickerResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ExercisePickerModal(),
    );
    if (result != null) {
      setState(() {
        _exercises.add(_WorkoutExerciseDraft(result.exercise.name, [
          _WorkoutSetDraft(reps: 10, weight: 0),
        ]));
      });
    }
  }

  Future<void> _showEditSetsModal(BuildContext context, _WorkoutExerciseDraft exercise, void Function(void Function()) setStateParent) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _EditSetsModal(
          exercise: exercise,
          onChanged: () => setStateParent(() {}),
        );
      },
    );
  }

  void _startWorkout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutInProgressPage(
          exercises: _exercises.map((e) => _WorkoutExerciseDraft(e.exerciseName, [
            ...e.sets.map((s) => _WorkoutSetDraft(reps: s.reps, weight: s.weight)),
          ])).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = 'Workout for ' + DateFormat.yMMMMd().format(_workoutDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date label at the very top
            Text(dateLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Preset/Generate buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: null, // Disabled for now
                    child: const Text('Presets'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: null, // Disabled for now
                    child: const Text('Generate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(child: Text('No exercises added yet.'))
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final ex = _exercises[index];
                        return Card(
                          child: ListTile(
                            title: Text(ex.exerciseName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: ex.sets
                                  .asMap()
                                  .entries
                                  .map((entry) => Text(
                                        'Set ${entry.key + 1}: ${entry.value.reps} x ${entry.value.weight.toInt()} lbs',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                      ))
                                  .toList(),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() => _exercises.removeAt(index));
                              },
                            ),
                            onTap: () async {
                              await _showEditSetsModal(context, ex, setState);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
              onPressed: _addExercise,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
              onPressed: _exercises.isEmpty ? null : _startWorkout,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePickerModal extends StatefulWidget {
  const _ExercisePickerModal();

  @override
  State<_ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<_ExercisePickerModal> {
  String _search = '';
  bool _byMuscle = false;
  List<Exercise> _allExercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await isar.exercises.where().findAll();
    setState(() {
      _allExercises = exercises;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allExercises
        .where((ex) => ex.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    // TODO: Sort by usage count (for now, just alphabetically)
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [_byMuscle == false, _byMuscle == true],
                  onPressed: (i) => setState(() => _byMuscle = i == 1),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('All'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('By Muscle'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (filtered.isEmpty)
              const Center(child: Text('No exercises found.'))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ex = filtered[index];
                    return ListTile(
                      title: Text(ex.name),
                      subtitle: Text(ex.muscleGroup.name),
                      onTap: () {
                        Navigator.of(context).pop(_ExercisePickerResult(ex));
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePickerResult {
  final Exercise exercise;
  _ExercisePickerResult(this.exercise);
}

// Temporary draft class for sets in the builder
class _WorkoutSetDraft {
  int reps;
  double weight;
  _WorkoutSetDraft({required this.reps, required this.weight});
}

// Temporary draft class for exercises in the builder
class _WorkoutExerciseDraft {
  final String exerciseName;
  List<_WorkoutSetDraft> sets;
  _WorkoutExerciseDraft(this.exerciseName, this.sets);

  String get setsSummary => sets.map((s) => '${s.reps} x ${s.weight} lbs').join(', ');
}

// Helper to get isar instance (assumes you have a global isar or use locator)
Isar get isarInstance => isar;

class WorkoutInProgressPage extends StatefulWidget {
  final List<_WorkoutExerciseDraft> exercises;
  const WorkoutInProgressPage({required this.exercises, Key? key}) : super(key: key);

  @override
  State<WorkoutInProgressPage> createState() => _WorkoutInProgressPageState();
}

class _WorkoutInProgressPageState extends State<WorkoutInProgressPage> {
  late final Stopwatch _stopwatch;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Store completed sets for each exercise by index
  final Map<int, List<CompletedSet>> _completedSets = {};

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0
        ? '${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}'
        : '${twoDigits(m)}:${twoDigits(s)}';
  }

  Future<void> _finishWorkout() async {
    final completedExercises = <CompletedExercise>[];
    for (int i = 0; i < widget.exercises.length; i++) {
      final ex = widget.exercises[i];
      final sets = _completedSets[i] ?? [];
      if (sets.isNotEmpty) {
        completedExercises.add(CompletedExercise()
          ..name = ex.exerciseName
          ..sets = sets);
      }
    }
    if (completedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No sets logged. Nothing to save.')));
      return;
    }
    final completedWorkout = CompletedWorkout()
      ..timestamp = DateTime.now()
      ..exercises = completedExercises;
    await isarInstance.writeTxn(() async {
      await isarInstance.completedWorkouts.put(completedWorkout);
    });
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryPage(
            duration: _elapsed,
            completedWorkout: completedWorkout,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                _formatDuration(_elapsed),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elapsed Time',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.deepPurple[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.deepPurple[300]),
                  const SizedBox(width: 8),
                  Text(
                    'Exercises',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ReorderableListView(
                  buildDefaultDragHandles: true,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final ex = widget.exercises.removeAt(oldIndex);
                      widget.exercises.insert(newIndex, ex);
                      // Move completed sets to match new order
                      final oldSets = _completedSets.remove(oldIndex);
                      // Shift all keys between oldIndex and newIndex
                      if (oldIndex < newIndex) {
                        for (int i = oldIndex + 1; i <= newIndex; i++) {
                          _completedSets[i - 1] = _completedSets.remove(i) ?? [];
                        }
                      } else {
                        for (int i = oldIndex - 1; i >= newIndex; i--) {
                          _completedSets[i + 1] = _completedSets.remove(i) ?? [];
                        }
                      }
                      if (oldSets != null) {
                        _completedSets[newIndex] = oldSets;
                      }
                    });
                  },
                  children: [
                    for (int index = 0; index < widget.exercises.length; index++)
                      Container(
                        key: ValueKey('exercise_$index'),
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final result = await Navigator.of(context).push<List<CompletedSet>>(
                                MaterialPageRoute(
                                  builder: (context) => ExerciseInProgressPage(
                                    exercise: widget.exercises[index],
                                    initialCompletedSets: _completedSets[index] ?? [],
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _completedSets[index] = result;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.exercises[index].exerciseName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...widget.exercises[index].sets.asMap().entries.map((entry) {
                                    final isLogged = (_completedSets[index]?.length ?? 0) > entry.key;
                                    return Text(
                                      'Set ${entry.key + 1}: ${entry.value.reps} x ${entry.value.weight.toInt()} lbs' + (isLogged ? '  ✔' : ''),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isLogged ? Colors.green[700] : Colors.grey[700],
                                        fontWeight: isLogged ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: const Text('Finish Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _finishWorkout,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ExerciseInProgressPage extends StatefulWidget {
  final _WorkoutExerciseDraft exercise;
  final List<CompletedSet> initialCompletedSets;
  const ExerciseInProgressPage({required this.exercise, this.initialCompletedSets = const [], Key? key}) : super(key: key);

  @override
  State<ExerciseInProgressPage> createState() => _ExerciseInProgressPageState();
}

class _ExerciseInProgressPageState extends State<ExerciseInProgressPage> {
  late List<_WorkoutSetDraft> sets;
  late List<bool> completed;
  late List<CompletedSet> loggedSets;
  int currentSet = 0;

  @override
  void initState() {
    super.initState();
    sets = widget.exercise.sets;
    completed = List.generate(sets.length, (i) => i < widget.initialCompletedSets.length);
    loggedSets = List<CompletedSet>.from(widget.initialCompletedSets);
    currentSet = completed.indexOf(false);
    if (currentSet == -1) currentSet = 0;
  }

  void _updateReps(int index, int newReps) {
    final oldReps = sets[index].reps;
    setState(() {
      sets[index].reps = newReps;
      for (int i = index + 1; i < sets.length; i++) {
        if (sets[i].reps == oldReps) {
          sets[i].reps = newReps;
        }
      }
    });
  }

  void _updateWeight(int index, double newWeight) {
    final oldWeight = sets[index].weight;
    setState(() {
      sets[index].weight = newWeight;
      for (int i = index + 1; i < sets.length; i++) {
        if (sets[i].weight == oldWeight) {
          sets[i].weight = newWeight;
        }
      }
    });
  }

  void _logCurrentSet() async {
    if (completed[currentSet]) return;
    setState(() {
      completed[currentSet] = true;
      loggedSets.add(CompletedSet()
        ..reps = sets[currentSet].reps
        ..weight = sets[currentSet].weight
        ..loggedAt = DateTime.now());
    });
    await showRestTimerModal(context, initialSeconds: 60);
    // Move to next incomplete set if any
    final next = completed.indexOf(false);
    if (next != -1) {
      setState(() => currentSet = next);
    }
  }

  void _onBack() {
    Navigator.of(context).pop(loggedSets);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise.exerciseName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sets', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: sets.length,
                  itemBuilder: (context, index) {
                    final set = sets[index];
                    final isCurrent = index == currentSet;
                    return GestureDetector(
                      onTap: () {
                        setState(() => currentSet = index);
                      },
                      child: Card(
                        color: completed[index]
                            ? Colors.green[100]
                            : isCurrent
                                ? Colors.deepPurple[100]
                                : null,
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: set.reps.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Reps'),
                                  onChanged: (val) {
                                    final reps = int.tryParse(val) ?? 0;
                                    _updateReps(index, reps);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: set.weight.toInt().toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                                  onChanged: (val) {
                                    final weight = int.tryParse(val) ?? 0;
                                    _updateWeight(index, weight.toDouble());
                                  },
                                ),
                              ),
                            ],
                          ),
                          trailing: completed[index]
                              ? const Icon(Icons.check, color: Colors.green)
                              : isCurrent
                                  ? const Icon(Icons.arrow_right, color: Colors.deepPurple)
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Log Set'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: completed[currentSet] ? Colors.grey : Colors.deepPurple,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: completed[currentSet] ? null : _logCurrentSet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showRestTimerModal(BuildContext context, {int initialSeconds = 60}) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    builder: (context) => _RestTimerModal(initialSeconds: initialSeconds),
  );
}

class _RestTimerModal extends StatefulWidget {
  final int initialSeconds;
  const _RestTimerModal({required this.initialSeconds});

  @override
  State<_RestTimerModal> createState() => _RestTimerModalState();
}

class _RestTimerModalState extends State<_RestTimerModal> {
  late int secondsLeft;
  Timer? timer;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.initialSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft > 0) {
        setState(() => secondsLeft--);
        if (secondsLeft == 0) {
          // Optionally play a sound here
          setState(() => finished = true);
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rest Timer', style: theme.textTheme.titleLarge?.copyWith(color: Colors.deepPurple)),
          const SizedBox(height: 16),
          Text(
            '${(secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(secondsLeft % 60).toString().padLeft(2, '0')}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: finished ? Colors.green : Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.deepPurple),
                iconSize: 36,
                onPressed: secondsLeft > 10
                    ? () => setState(() => secondsLeft -= 10)
                    : null,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                iconSize: 36,
                onPressed: () => setState(() => secondsLeft += 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: Text(finished ? 'Done' : 'Skip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: finished ? Colors.green : Colors.deepPurple,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EditSetsModal extends StatefulWidget {
  final _WorkoutExerciseDraft exercise;
  final VoidCallback onChanged;
  const _EditSetsModal({required this.exercise, required this.onChanged});

  @override
  State<_EditSetsModal> createState() => _EditSetsModalState();
}

class _EditSetsModalState extends State<_EditSetsModal> {
  late List<_WorkoutSetDraft> sets;

  @override
  void initState() {
    super.initState();
    sets = widget.exercise.sets;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Sets', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return Row(
                children: [
                  Text('Set ${index + 1}'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: set.reps.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      onChanged: (val) {
                        final reps = int.tryParse(val) ?? 0;
                        setState(() => set.reps = reps);
                        widget.onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: set.weight.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                      onChanged: (val) {
                        final weight = int.tryParse(val) ?? 0;
                        setState(() => set.weight = weight.toDouble());
                        widget.onChanged();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: sets.length > 1
                        ? () {
                            setState(() => sets.removeAt(index));
                            widget.onChanged();
                          }
                        : null,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
                onPressed: () {
                  if (sets.isNotEmpty) {
                    final last = sets.last;
                    setState(() => sets.add(_WorkoutSetDraft(reps: last.reps, weight: last.weight)));
                  } else {
                    setState(() => sets.add(_WorkoutSetDraft(reps: 10, weight: 0)));
                  }
                  widget.onChanged();
                },
              ),
              const Spacer(),
              ElevatedButton(
                child: const Text('Done'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showWorkoutSummaryDialog(BuildContext context, {
  required Duration duration,
  required List<CompletedExercise> exercises,
}) async {
  // Calculate muscles worked and total pounds lifted
  final muscleGroups = <String>{};
  double totalPounds = 0;
  for (final ex in exercises) {
    final exercise = await isar.exercises.filter().nameEqualTo(ex.name).findFirst();
    if (exercise != null) {
      muscleGroups.add(exercise.muscleGroup.name);
    }
    for (final set in ex.sets) {
      totalPounds += set.reps * set.weight;
    }
  }
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Workout Complete!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duration: ${duration.inMinutes} min ${duration.inSeconds % 60} sec'),
          const SizedBox(height: 8),
          Text('Muscles worked: ${muscleGroups.join(", ")}'),
          const SizedBox(height: 8),
          Text('Total pounds lifted: ${totalPounds.toStringAsFixed(0)} lbs'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class WorkoutSummaryPage extends StatelessWidget {
  final Duration duration;
  final CompletedWorkout completedWorkout;
  const WorkoutSummaryPage({required this.duration, required this.completedWorkout, Key? key}) : super(key: key);

  Future<Set<String>> _getMusclesWorked() async {
    final muscleGroups = <String>{};
    for (final ex in completedWorkout.exercises) {
      final exercise = await isar.exercises.filter().nameEqualTo(ex.name).findFirst();
      if (exercise != null) {
        muscleGroups.add(exercise.muscleGroup.name);
      }
    }
    return muscleGroups;
  }

  double get totalPounds {
    double total = 0;
    for (final ex in completedWorkout.exercises) {
      for (final set in ex.sets) {
        total += set.reps * set.weight;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Set<String>>(
        future: _getMusclesWorked(),
        builder: (context, snapshot) {
          final muscles = snapshot.data ?? {};
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workout Complete!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Duration: ${duration.inMinutes} min ${duration.inSeconds % 60} sec', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Muscles worked: ${muscles.isEmpty ? "-" : muscles.join(", ")}', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Total pounds lifted: ${totalPounds.toStringAsFixed(0)} lbs', style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                Text('Breakdown:', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: completedWorkout.exercises.length,
                    itemBuilder: (context, i) {
                      final ex = completedWorkout.exercises[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ...ex.sets.asMap().entries.map((entry) => Text(
                                    'Set ${entry.key + 1}: ${entry.value.reps} x ${entry.value.weight.toInt()} lbs',
                                    style: theme.textTheme.bodyMedium,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/workouts');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 