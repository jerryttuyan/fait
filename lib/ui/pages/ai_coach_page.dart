import 'package:flutter/material.dart';
import '../../utils/ai_service.dart';
import 'dart:convert';
import 'workout_builder_page.dart';
import '../../data/exercise.dart';
import '../../data/workout_draft.dart';
import '../../data/workout.dart';
import 'package:isar/isar.dart';
import '../../main.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AICoachPage extends StatefulWidget {
  const AICoachPage({super.key});

  @override
  State<AICoachPage> createState() => _AICoachPageState();
}

class _AICoachPageState extends State<AICoachPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hi! I'm your AI fitness coach. I can help you with workout advice, nutrition tips, and answer questions about your fitness journey. What would you like to know?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _questionController.clear();

    // Build chat history for context (last 10 messages)
    final chatHistory = _messages.takeLast(10).map((msg) => {
      'role': msg.isUser ? 'user' : 'assistant',
      'content': msg.text,
    }).toList();

    // Get AI response, passing chat history
    final response = await _getAIResponse(question, chatHistory: chatHistory);

    // Try to extract JSON array from anywhere in the response
    final jsonArrayRegex = RegExp(r'(\[\s*{[\s\S]*?}\s*\])');
    final match = jsonArrayRegex.firstMatch(response);
    String? beforeJson;
    String? afterJson;
    String? jsonString;
    if (match != null) {
      jsonString = match.group(1);
      beforeJson = response.substring(0, match.start).trim();
      afterJson = response.substring(match.end).trim();
    }

    bool isWorkoutJson = false;
    List<WorkoutExerciseDraft> aiExercises = [];
    if (jsonString != null) {
      try {
        final List<dynamic> workoutList = jsonDecode(jsonString);
        if (workoutList is List) {
          isWorkoutJson = true;
          // Fetch completed workouts for weight lookup
          final isarInstance = Isar.getInstance();
          final completedWorkouts = isarInstance != null
            ? await isarInstance.completedWorkouts.where().findAll()
            : <CompletedWorkout>[];
          for (var workout in workoutList) {
            final name = workout['name'] as String?;
            final setsStr = workout['sets'].toString();
            final repsStr = workout['reps'].toString();
            final sets = int.tryParse(setsStr) ?? 3;
            final reps = int.tryParse(repsStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
            double weight = 0;
            if (workout.containsKey('weight')) {
              final w = workout['weight'];
              if (w is num) weight = w.toDouble();
              else if (w is String) weight = double.tryParse(w) ?? 0;
            }
            // If weight is missing or 0, look up user history
            if (weight == 0 && name != null) {
              double? bestWeight;
              for (final cw in completedWorkouts) {
                for (final ex in cw.exercises) {
                  if (ex.name == name) {
                    for (final set in ex.sets) {
                      if (bestWeight == null || set.weight > bestWeight) {
                        bestWeight = set.weight;
                      }
                    }
                  }
                }
              }
              if (bestWeight != null) {
                weight = bestWeight;
              } else {
                // Use a default based on exercise type
                final lowerName = name.toLowerCase();
                if (lowerName.contains('dumbbell')) {
                  weight = 10;
                } else if (lowerName.contains('barbell')) {
                  weight = 45;
                } else {
                  weight = 20;
                }
              }
            }
            final setsList = List.generate(sets, (index) => WorkoutSetDraft(reps: reps, weight: weight));
            aiExercises.add(WorkoutExerciseDraft(name ?? 'Exercise', setsList));
          }
        }
      } catch (e) {
        // Not JSON, treat as normal text
      }
    }

    setState(() {
      if (beforeJson != null && beforeJson.isNotEmpty) {
        _messages.add(ChatMessage(
          text: beforeJson,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
      if (isWorkoutJson && aiExercises.isNotEmpty) {
        _messages.add(ChatMessage(
          text: '{AI_WORKOUT_JSON}',
          isUser: false,
          timestamp: DateTime.now(),
          aiWorkoutExercises: aiExercises,
        ));
      }
      if (afterJson != null && afterJson.isNotEmpty) {
        _messages.add(ChatMessage(
          text: afterJson,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
      if (!isWorkoutJson && (beforeJson == null || beforeJson.isEmpty)) {
        // Only show plain text if there was no message and no workout JSON
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
      _isLoading = false;
    });
  }

  Future<String> _getAIResponse(String question, {List<Map<String, String>>? chatHistory}) async {
    await Future.delayed(const Duration(seconds: 1));
    return await _aiService.getAIResponse(question, chatHistory: chatHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start New Chat',
            onPressed: _resetChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('AI is thinking...'),
                      ],
                    ),
                  );
                }
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: "Hi! I'm your AI fitness coach. I can help you with workout advice, nutrition tips, and answer questions about your fitness journey. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<WorkoutExerciseDraft>? aiWorkoutExercises;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.aiWorkoutExercises,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Special rendering for AI workout JSON
    if (message.text == '{AI_WORKOUT_JSON}' && message.aiWorkoutExercises != null) {
      final exercises = message.aiWorkoutExercises!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI-Generated Workout Plan:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...exercises.map((ex) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${ex.exerciseName}: ${ex.sets.length} sets x ${ex.sets.isNotEmpty ? ex.sets[0].reps : '?'} reps',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text('Use This Workout'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutBuilderPage(initialExercises: exercises),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    // Default chat bubble
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.fitness_center, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: message.isUser
                ? Text(
                    message.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      strong: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// Add this extension for takeLast
extension ListUtils<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? List<T>.from(this) : sublist(length - n);
} 