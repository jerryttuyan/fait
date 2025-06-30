import 'package:isar/isar.dart';
import 'package:dart_openai/dart_openai.dart';
import '../data/user_profile.dart';
import '../data/workout.dart';
import '../data/weight_entry.dart';
import '../data/exercise.dart';
import '../data/enums.dart' as data_enums;
import '../main.dart';
import '../config/api_config.dart';
import '../utils/recovery_calculator.dart';
import '../utils/weight_calculator.dart' as calc_utils;
import '../utils/calculators.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Initialize OpenAI (call this in main.dart)
  static void initializeOpenAI() {
    if (ApiConfig.useOpenAI) {
      OpenAI.apiKey = ApiConfig.openaiApiKey;
      OpenAI.baseUrl = 'https://api.openai.com';
    }
  }

  /// Get AI response with hybrid approach
  Future<String> getAIResponse(String question, {List<Map<String, String>>? chatHistory}) async {
    // Get user context
    final context = await getUserContext();

    // --- Calculate BMI, RMR, and Macros ---
    double? bmiValue;
    double? rmrValue;
    double? tdeeValue;
    calc_utils.MacronutrientNeeds? macros;
    String? bmiCategory;
    final userProfile = context['userProfile'] as UserProfile?;
    final weightEntries = context['weightEntries'] as List<WeightEntry>;
    final completedWorkouts = context['completedWorkouts'] as List<CompletedWorkout>;
    final exercises = context['exercises'] as List<Exercise>;
    Map<data_enums.MuscleGroup, double> recoveryMap = {};
    try {
      recoveryMap = await RecoveryCalculator.calculateRecovery(completedWorkouts);
    } catch (e) {
      print('Error calculating recovery: $e');
    }
    if (userProfile != null && userProfile.heightIn != null && userProfile.age != null && weightEntries.isNotEmpty) {
      final latestWeight = weightEntries.last.weight;
      final heightIn = userProfile.heightIn!;
      final age = userProfile.age!;
      final gender = userProfile.gender;
      // Imperial to metric
      final weightKg = latestWeight * 0.453592;
      final heightCm = heightIn * 2.54;
      bmiValue = bmi(lb: latestWeight, inches: heightIn);
      rmrValue = rmr(lb: latestWeight, inches: heightIn, age: age, gender: gender);
      final calcGender = gender == data_enums.Gender.male ? calc_utils.Gender.male : calc_utils.Gender.female;
      final activityLevel = userProfile.activityLevel;
      final goal = userProfile.weightGoal;
      final result = calc_utils.getWeightManagementPlan(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: calcGender,
        activityLevel: calc_utils.ActivityLevel.values[activityLevel.index],
        goal: calc_utils.WeightGoal.values[goal.index],
      );
      tdeeValue = result.tdee;
      macros = result.macros;
      bmiCategory = result.bmiCategory;
    }

    // Build conversation history for OpenAI
    List<Map<String, String>> history = chatHistory ?? [];

    // Build context string
    String contextString = "You are the AI Coach in the Fait app. ";
    if (userProfile != null) {
      contextString += "User Profile: ";
      contextString += "${userProfile.name ?? 'Unknown'}, Age: ${userProfile.age}, Gender: ${userProfile.gender}, Height: ${userProfile.heightIn} in, Activity Level: ${userProfile.activityLevel}, Weight Goal: ${userProfile.weightGoal}. ";
    }
    if (weightEntries.isNotEmpty) {
      final latestWeight = weightEntries.last.weight;
      contextString += "Current weight: ${latestWeight} lbs. ";
    }
    if (bmiValue != null && rmrValue != null && tdeeValue != null && macros != null && bmiCategory != null) {
      contextString += "BMI: ${bmiValue.toStringAsFixed(1)} (${bmiCategory}), RMR: ${rmrValue.round()} kcal/day, TDEE: ${tdeeValue.round()} kcal/day. ";
      contextString += "Macros: Protein: ${macros.protein.round()}g, Carbs: ${macros.carbs.round()}g, Fat: ${macros.fat.round()}g, Calories: ${macros.calories.round()}. ";
    }
    String availableExercises = exercises.isNotEmpty
        ? exercises.map((e) =>
            "${e.name} (Muscle groups: ${e.muscleGroups.join(', ')})").join('; ')
        : 'None';
    String recentWorkouts = completedWorkouts.isNotEmpty
        ? completedWorkouts.take(5).map((w) {
            final date = w.timestamp.toLocal().toString().split(' ')[0];
            final allExercises = context['exercises'] as List<Exercise>;
            final muscles = w.exercises
              .map((ex) {
                final found = allExercises.where((e) => e.name == ex.name);
                return found.isNotEmpty ? found.first.muscleGroups : <String>[];
              })
              .expand((groups) => groups)
              .toSet()
              .join(', ');
            return "$date: ${w.exercises.map((ex) => ex.name).join(', ')} (Muscles: $muscles)";
          }).join(' | ')
        : 'No recent workouts.';
    String muscleRecovery = recoveryMap.isNotEmpty
        ? recoveryMap.entries.map((e) =>
            "${e.key.name}: ${(e.value * 100).toStringAsFixed(0)}% recovered").join('; ')
        : 'No recovery data.';

    // Build prompt
    String prompt = '''
$contextString

User Question: $question

As Fait's AI Coach, you are a friendly, knowledgeable, and concise fitness assistant inside the Fait app. Always be helpful, positive, and encouraging, but keep your responses brief and to the point. Use the user's data and context to personalize advice. If you provide a workout plan, give a short, natural explanation, then only include the JSON array of the plan. Do not list the workout in Markdown, text, or any other format. Never show the workout plan twice. Never omit the JSON array. Do not mention JSON, code, or formatting in your user-facing responses.

Example workout plan format (do not mention this to the user):
[
  {"name": "Barbell Bench Press", "sets": 3, "reps": 8, "weight": 95, "notes": ""},
  {"name": "Dumbbell Row", "sets": 3, "reps": 10, "weight": 30, "notes": ""}
]
''';

    // Build OpenAI messages array with history
    final messages = <dynamic>[];
    messages.add({
      'role': 'system',
      'content': "You are Fait's AI Coach, a friendly, knowledgeable, and concise fitness assistant inside the Fait app. Always be helpful, positive, and encouraging, but keep your responses brief and to the point. Use the user's data and context to personalize advice. If you provide a workout plan, give a short, natural explanation, then only include the JSON array of the plan. Do not list the workout in Markdown, text, or any other format. Never show the workout plan twice. Never omit the JSON array. Do not mention JSON, code, or formatting in your user-facing responses."
    });
    for (final entry in history) {
      messages.add({
        'role': entry['role'] ?? 'user',
        'content': entry['content'] ?? '',
      });
    }
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    // Use OpenAI for all questions
    if (ApiConfig.useOpenAI) {
      try {
        final completion = await OpenAI.instance.chat.create(
          model: ApiConfig.defaultModel,
          messages: messages.map((m) =>
            OpenAIChatCompletionChoiceMessageModel(
              role: m['role'] == 'system' ? OpenAIChatMessageRole.system :
                    m['role'] == 'assistant' ? OpenAIChatMessageRole.assistant :
                    OpenAIChatMessageRole.user,
              content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(m['content'])],
            )
          ).toList(),
          maxTokens: ApiConfig.maxTokens,
          temperature: ApiConfig.temperature,
        );
        final contentList = completion.choices.first.message.content;
        if (contentList != null && contentList.isNotEmpty && contentList.first.text != null) {
          return contentList.first.text!;
        } else {
          return 'I apologize, but I couldn\'t generate a response right now. Please try again.';
        }
      } catch (e) {
        print('OpenAI API error: $e');
        // Fallback to hard-coded response
        return await _getHardcodedResponse(question, context);
      }
    }
    // Default to hard-coded response
    return await _getHardcodedResponse(question, context);
  }

  /// Determine if we should use hard-coded responses
  bool _shouldUseHardcodedResponse(String question) {
    final lowerQuestion = question.toLowerCase();
    
    // Use hard-coded for structured requests
    return lowerQuestion.contains('generate') ||
           lowerQuestion.contains('create') ||
           lowerQuestion.contains('plan') ||
           lowerQuestion.contains('calculate') ||
           lowerQuestion.contains('analyze') ||
           lowerQuestion.contains('track') ||
           lowerQuestion.contains('nutrition') ||
           lowerQuestion.contains('calories') ||
           lowerQuestion.contains('macros');
  }

  /// Get OpenAI response
  Future<String> _getOpenAIResponse(String question, Map<String, dynamic> context) async {
    final userProfile = context['userProfile'] as UserProfile?;
    final weightEntries = context['weightEntries'] as List<WeightEntry>;
    final completedWorkouts = context['completedWorkouts'] as List<CompletedWorkout>;
    final exercises = context['exercises'] as List<Exercise>;

    // --- NEW: Calculate muscle recovery ---
    Map<data_enums.MuscleGroup, double> recoveryMap = {};
    try {
      recoveryMap = await RecoveryCalculator.calculateRecovery(completedWorkouts);
    } catch (e) {
      print('Error calculating recovery: $e');
    }

    // --- Format available exercises with muscle groups ---
    String availableExercises = exercises.isNotEmpty
        ? exercises.map((e) =>
            "${e.name} (Muscle groups: ${e.muscleGroups.join(', ')})").join('; ')
        : 'None';

    // --- Summarize recent workouts ---
    String recentWorkouts = completedWorkouts.isNotEmpty
        ? completedWorkouts.take(5).map((w) {
            final date = w.timestamp.toLocal().toString().split(' ')[0];
            final allExercises = context['exercises'] as List<Exercise>;
            final muscles = w.exercises
              .map((ex) {
                final found = allExercises.where((e) => e.name == ex.name);
                return found.isNotEmpty ? found.first.muscleGroups : <String>[];
              })
              .expand((groups) => groups)
              .toSet()
              .join(', ');
            return "$date: ${w.exercises.map((ex) => ex.name).join(', ')} (Muscles: $muscles)";
          }).join(' | ')
        : 'No recent workouts.';

    // --- Format muscle recovery status ---
    String muscleRecovery = recoveryMap.isNotEmpty
        ? recoveryMap.entries.map((e) =>
            "${e.key.name}: ${(e.value * 100).toStringAsFixed(0)}% recovered").join('; ')
        : 'No recovery data.';

    // --- Build context string ---
    String contextString = "You are an AI fitness coach for a mobile app called Fait. ";
    if (userProfile != null) {
      contextString += "User Profile: ";
      contextString += "${userProfile.name ?? 'Unknown'}, Age: ${userProfile.age}, Gender: ${userProfile.gender}, Activity Level: ${userProfile.activityLevel}, Weight Goal: ${userProfile.weightGoal}. ";
    }
    if (weightEntries.isNotEmpty) {
      final latestWeight = weightEntries.last.weight;
      contextString += "Current weight: ${latestWeight}lbs. ";
    }
    contextString += "Available exercises: $availableExercises. ";
    contextString += "Recent workouts: $recentWorkouts. ";
    contextString += "Muscle recovery status: $muscleRecovery. ";

    // --- Build prompt with clear instructions for JSON output ---
    final prompt = '''
$contextString

User Question: $question

When generating a workout plan, only use exercises from the provided list, and avoid assigning exercises to muscle groups that are less than 80% recovered. For each exercise, suggest a realistic number of reps (6-15) and sets (2-5). For weight, use the user's previous best for that exercise if available, or a reasonable default (e.g., 10 lbs for dumbbells, 45 lbs for barbells). Return the weight as a number in pounds for each exercise. Respond ONLY with a JSON array of workout objects, each with: "name", "sets", "reps", "weight", and "notes". Example:
[
  {"name": "Barbell Bench Press", "sets": 3, "reps": 8, "weight": 95, "notes": ""},
  {"name": "Dumbbell Row", "sets": 3, "reps": 10, "weight": 30, "notes": ""}
]
''';

    try {
      final completion = await OpenAI.instance.chat.create(
        model: ApiConfig.defaultModel,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a knowledgeable and encouraging AI fitness coach. Provide helpful, personalized advice based on the user\'s data and questions.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        maxTokens: ApiConfig.maxTokens,
        temperature: ApiConfig.temperature,
      );

      final contentList = completion.choices.first.message.content;
      if (contentList != null && contentList.isNotEmpty && contentList.first.text != null) {
        return contentList.first.text!;
      } else {
        return 'I apologize, but I couldn\'t generate a response right now. Please try again.';
      }
    } catch (e) {
      throw Exception('OpenAI API error: $e');
    }
  }

  /// Get hard-coded response (existing logic)
  Future<String> _getHardcodedResponse(String question, Map<String, dynamic> context) async {
    final lowerQuestion = question.toLowerCase();
    
    // Check for specific workout plan requests
    if (lowerQuestion.contains('generate') || lowerQuestion.contains('create') || lowerQuestion.contains('plan')) {
      if (lowerQuestion.contains('workout') || lowerQuestion.contains('exercise')) {
        return await _handleWorkoutPlanRequest(question);
      }
    }
    
    // Check for nutrition requests
    if (lowerQuestion.contains('nutrition') || lowerQuestion.contains('diet') || lowerQuestion.contains('food') || lowerQuestion.contains('calories')) {
      return await getNutritionAdvice();
    }
    
    // Check for progress analysis
    if (lowerQuestion.contains('progress') || lowerQuestion.contains('track') || lowerQuestion.contains('analysis')) {
      return await analyzeProgress();
    }
    
    // General fitness advice
    if (lowerQuestion.contains('workout') || lowerQuestion.contains('exercise')) {
      if (lowerQuestion.contains('recommend') || lowerQuestion.contains('suggest')) {
        return await _recommendExercises();
      } else {
        return "I can help you with workouts! I can generate personalized workout plans, recommend exercises, or answer specific questions about your training. What would you like to know?";
      }
    } else if (lowerQuestion.contains('weight') || lowerQuestion.contains('lose') || lowerQuestion.contains('gain')) {
      return await _getWeightAdvice();
    } else if (lowerQuestion.contains('recovery') || lowerQuestion.contains('rest')) {
      return await _getRecoveryAdvice();
    } else {
      return "I'm here to help with your fitness journey! I can assist with:\n\n• **Workout Planning:** Generate personalized workout plans\n• **Nutrition:** Get calorie and macro recommendations\n• **Progress Tracking:** Analyze your weight and workout data\n• **Exercise Recommendations:** Suggest exercises based on your level\n• **Recovery Advice:** Tips for rest and recovery\n\nWhat specific area would you like to focus on?";
    }
  }

  /// Get user context for AI responses
  Future<Map<String, dynamic>> getUserContext() async {
    final userProfile = await isar.userProfiles.get(1);
    final weightEntries = await isar.weightEntrys.where().findAll();
    final completedWorkouts = await isar.completedWorkouts.where().findAll();
    final exercises = await isar.exercises.where().findAll();

    return {
      'userProfile': userProfile,
      'weightEntries': weightEntries,
      'completedWorkouts': completedWorkouts,
      'exercises': exercises,
    };
  }

  /// Generate a personalized workout plan
  Future<String> generateWorkoutPlan({
    required String focus,
    required int daysPerWeek,
    required String difficulty,
  }) async {
    final context = await getUserContext();
    final exercises = context['exercises'] as List<Exercise>;
    final userProfile = context['userProfile'] as UserProfile?;

    if (exercises.isEmpty) {
      return "I don't have any exercises in my database yet. Please add some exercises first!";
    }

    // Filter exercises based on focus and difficulty
    List<Exercise> filteredExercises = exercises.where((e) {
      if (difficulty == 'beginner' && e.difficulty != data_enums.Difficulty.beginner) return false;
      if (difficulty == 'intermediate' && e.difficulty == data_enums.Difficulty.advanced) return false;
      return true;
    }).toList();

    String plan = "**Your Personalized $focus Workout Plan**\n\n";
    plan += "**Frequency:** $daysPerWeek days per week\n";
    plan += "**Difficulty:** $difficulty\n\n";

    // Generate different splits based on days per week
    if (daysPerWeek <= 3) {
      plan += _generateFullBodyPlan(filteredExercises, daysPerWeek);
    } else if (daysPerWeek <= 4) {
      plan += _generateUpperLowerPlan(filteredExercises, daysPerWeek);
    } else {
      plan += _generatePushPullLegsPlan(filteredExercises, daysPerWeek);
    }

    return plan;
  }

  String _generateFullBodyPlan(List<Exercise> exercises, int daysPerWeek) {
    String plan = "**Full Body Split**\n\n";
    
    final compoundExercises = exercises.where((e) => 
      e.equipment == data_enums.EquipmentType.barbell || 
      e.equipment == data_enums.EquipmentType.dumbbell
    ).take(6).toList();
    
    final isolationExercises = exercises.where((e) => 
      e.equipment == data_enums.EquipmentType.dumbbell || 
      e.equipment == data_enums.EquipmentType.machine
    ).take(4).toList();

    plan += "**Workout A (Day 1):**\n";
    for (var exercise in compoundExercises.take(3)) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }
    for (var exercise in isolationExercises.take(2)) {
      plan += "• ${exercise.name}: 3 sets x 10-15 reps\n";
    }

    if (daysPerWeek >= 2) {
      plan += "\n**Workout B (Day 2):**\n";
      for (var exercise in compoundExercises.skip(3).take(3)) {
        plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
      }
      for (var exercise in isolationExercises.skip(2).take(2)) {
        plan += "• ${exercise.name}: 3 sets x 10-15 reps\n";
      }
    }

    if (daysPerWeek >= 3) {
      plan += "\n**Workout C (Day 3):**\n";
      plan += "• Repeat Workout A with different variations\n";
    }

    plan += "\n**Rest:** 60-90 seconds between sets\n";
    plan += "**Progression:** Increase weight when you can complete all sets with good form\n";
    
    return plan;
  }

  String _generateUpperLowerPlan(List<Exercise> exercises, int daysPerWeek) {
    String plan = "**Upper/Lower Split**\n\n";
    
    final upperExercises = exercises.where((e) => 
      e.primaryMuscle.contains('chest') || 
      e.primaryMuscle.contains('back') || 
      e.primaryMuscle.contains('shoulders') || 
      e.primaryMuscle.contains('biceps') || 
      e.primaryMuscle.contains('triceps')
    ).take(8).toList();
    
    final lowerExercises = exercises.where((e) => 
      e.primaryMuscle.contains('legs') || 
      e.primaryMuscle.contains('glutes') || 
      e.primaryMuscle.contains('quadriceps') || 
      e.primaryMuscle.contains('hamstrings')
    ).take(6).toList();

    plan += "**Upper Body (Days 1 & 3):**\n";
    for (var exercise in upperExercises) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }

    plan += "\n**Lower Body (Days 2 & 4):**\n";
    for (var exercise in lowerExercises) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }

    plan += "\n**Rest:** 60-90 seconds between sets\n";
    plan += "**Schedule:** Upper-Lower-Rest-Upper-Lower-Rest-Rest\n";
    
    return plan;
  }

  String _generatePushPullLegsPlan(List<Exercise> exercises, int daysPerWeek) {
    String plan = "**Push/Pull/Legs Split**\n\n";
    
    final pushExercises = exercises.where((e) => 
      e.pushPullType == data_enums.PushPullType.push
    ).take(6).toList();
    
    final pullExercises = exercises.where((e) => 
      e.pushPullType == data_enums.PushPullType.pull
    ).take(6).toList();
    
    final legExercises = exercises.where((e) => 
      e.pushPullType == data_enums.PushPullType.legs
    ).take(6).toList();

    plan += "**Push Day (Chest, Shoulders, Triceps):**\n";
    for (var exercise in pushExercises) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }

    plan += "\n**Pull Day (Back, Biceps):**\n";
    for (var exercise in pullExercises) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }

    plan += "\n**Legs Day (Quads, Hamstrings, Glutes):**\n";
    for (var exercise in legExercises) {
      plan += "• ${exercise.name}: 3 sets x 8-12 reps\n";
    }

    plan += "\n**Rest:** 60-90 seconds between sets\n";
    plan += "**Schedule:** Push-Pull-Legs-Rest-Push-Pull-Legs-Rest\n";
    
    return plan;
  }

  /// Get nutrition advice based on user profile
  Future<String> getNutritionAdvice() async {
    final context = await getUserContext();
    final userProfile = context['userProfile'] as UserProfile?;

    if (userProfile == null) {
      return "I need your profile information to give you personalized nutrition advice. Please complete your profile first!";
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr = 0;
    if (userProfile.gender == data_enums.Gender.male) {
      bmr = 10 * (userProfile.heightIn ?? 70) + 6.25 * (userProfile.heightIn ?? 70) - 5 * (userProfile.age ?? 25) + 5;
    } else {
      bmr = 10 * (userProfile.heightIn ?? 70) + 6.25 * (userProfile.heightIn ?? 70) - 5 * (userProfile.age ?? 25) - 161;
    }

    // Apply activity multiplier
    double tdee = bmr;
    switch (userProfile.activityLevel) {
      case data_enums.ActivityLevel.sedentary:
        tdee = bmr * 1.2;
        break;
      case data_enums.ActivityLevel.lightlyActive:
        tdee = bmr * 1.375;
        break;
      case data_enums.ActivityLevel.moderatelyActive:
        tdee = bmr * 1.55;
        break;
      case data_enums.ActivityLevel.veryActive:
        tdee = bmr * 1.725;
        break;
      case data_enums.ActivityLevel.extraActive:
        tdee = bmr * 1.9;
        break;
    }

    // Adjust for weight goal
    double targetCalories = tdee;
    switch (userProfile.weightGoal) {
      case data_enums.WeightGoal.weightLoss:
        targetCalories = tdee - 500; // 500 calorie deficit
        break;
      case data_enums.WeightGoal.weightGain:
        targetCalories = tdee + 300; // 300 calorie surplus
        break;
      case data_enums.WeightGoal.maintenance:
        targetCalories = tdee;
        break;
    }

    String advice = "**Your Personalized Nutrition Plan**\n\n";
    advice += "**Daily Calorie Target:** ${targetCalories.round()} calories\n\n";
    
    // Calculate macros
    double proteinGrams = (userProfile.heightIn ?? 70) * 2.2; // 1g per lb body weight
    double fatGrams = (targetCalories * 0.25) / 9; // 25% of calories from fat
    double carbGrams = (targetCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4;

    advice += "**Macronutrient Breakdown:**\n";
    advice += "• **Protein:** ${proteinGrams.round()}g (${(proteinGrams * 4).round()} calories)\n";
    advice += "• **Fat:** ${fatGrams.round()}g (${(fatGrams * 9).round()} calories)\n";
    advice += "• **Carbs:** ${carbGrams.round()}g (${(carbGrams * 4).round()} calories)\n\n";

    advice += "**Key Recommendations:**\n";
    advice += "• Eat protein with every meal\n";
    advice += "• Include healthy fats (nuts, avocados, olive oil)\n";
    advice += "• Choose complex carbs (oats, brown rice, sweet potatoes)\n";
    advice += "• Stay hydrated (aim for 8-10 glasses of water daily)\n";
    advice += "• Time protein intake around workouts\n";

    return advice;
  }

  /// Analyze user progress
  Future<String> analyzeProgress() async {
    final context = await getUserContext();
    final weightEntries = context['weightEntries'] as List<WeightEntry>;
    final completedWorkouts = context['completedWorkouts'] as List<CompletedWorkout>;
    final userProfile = context['userProfile'] as UserProfile?;

    String analysis = "**Your Progress Analysis**\n\n";

    // Weight analysis
    if (weightEntries.isNotEmpty) {
      final firstWeight = weightEntries.first.weight;
      final lastWeight = weightEntries.last.weight;
      final weightChange = lastWeight - firstWeight;
      final changeText = weightChange > 0 ? "gained" : weightChange < 0 ? "lost" : "maintained";
      final absChange = weightChange.abs();
      
      analysis += "**Weight Progress:**\n";
      analysis += "• Starting weight: ${firstWeight.toStringAsFixed(1)} lbs\n";
      analysis += "• Current weight: ${lastWeight.toStringAsFixed(1)} lbs\n";
      analysis += "• Total change: $changeText ${absChange.toStringAsFixed(1)} lbs\n\n";

      // Calculate weekly rate
      if (weightEntries.length > 1) {
        final daysBetween = weightEntries.last.date.difference(weightEntries.first.date).inDays;
        final weeklyRate = (absChange / daysBetween) * 7;
        analysis += "• Weekly rate: ${weeklyRate.toStringAsFixed(1)} lbs per week\n\n";
      }
    }

    // Workout analysis
    if (completedWorkouts.isNotEmpty) {
      analysis += "**Workout Progress:**\n";
      analysis += "• Total workouts completed: ${completedWorkouts.length}\n";
      
      final recentWorkouts = completedWorkouts.where((w) => 
        w.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)))
      ).length;
      analysis += "• Workouts in last 30 days: $recentWorkouts\n";

      // Calculate average workout duration
      final workoutsWithDuration = completedWorkouts.where((w) => w.durationSeconds != null).toList();
      if (workoutsWithDuration.isNotEmpty) {
        final avgDuration = workoutsWithDuration.map((w) => w.durationSeconds!).reduce((a, b) => a + b) / workoutsWithDuration.length;
        analysis += "• Average workout duration: ${(avgDuration / 60).round()} minutes\n";
      }
      analysis += "\n";
    }

    // Recommendations
    analysis += "**Recommendations:**\n";
    if (userProfile != null) {
      switch (userProfile.weightGoal) {
        case data_enums.WeightGoal.weightLoss:
          if (weightEntries.isNotEmpty) {
            final lastWeight = weightEntries.last.weight;
            final firstWeight = weightEntries.first.weight;
            if (lastWeight > firstWeight) {
              analysis += "• Consider reducing calorie intake or increasing activity\n";
            } else if (lastWeight < firstWeight) {
              analysis += "• Great progress! Keep up the consistent effort\n";
            }
          }
          break;
        case data_enums.WeightGoal.weightGain:
          if (weightEntries.isNotEmpty) {
            final lastWeight = weightEntries.last.weight;
            final firstWeight = weightEntries.first.weight;
            if (lastWeight < firstWeight) {
              analysis += "• Consider increasing calorie intake\n";
            } else if (lastWeight > firstWeight) {
              analysis += "• Excellent progress! Continue with your current approach\n";
            }
          }
          break;
        case data_enums.WeightGoal.maintenance:
          analysis += "• Focus on body composition and strength gains\n";
          break;
      }
    }

    analysis += "• Track your progress consistently\n";
    analysis += "• Celebrate non-scale victories\n";
    analysis += "• Adjust your plan based on results\n";

    return analysis;
  }

  Future<String> _handleWorkoutPlanRequest(String question) async {
    final lowerQuestion = question.toLowerCase();
    
    // Extract parameters from the question
    String focus = "Strength Training";
    int daysPerWeek = 3;
    String difficulty = "beginner";
    
    // Determine focus
    if (lowerQuestion.contains('strength') || lowerQuestion.contains('muscle')) {
      focus = "Strength Training";
    } else if (lowerQuestion.contains('cardio') || lowerQuestion.contains('endurance')) {
      focus = "Cardiovascular Training";
    } else if (lowerQuestion.contains('weight loss') || lowerQuestion.contains('fat loss')) {
      focus = "Weight Loss";
    } else if (lowerQuestion.contains('toning') || lowerQuestion.contains('definition')) {
      focus = "Muscle Toning";
    }
    
    // Determine frequency
    if (lowerQuestion.contains('3') || lowerQuestion.contains('three')) {
      daysPerWeek = 3;
    } else if (lowerQuestion.contains('4') || lowerQuestion.contains('four')) {
      daysPerWeek = 4;
    } else if (lowerQuestion.contains('5') || lowerQuestion.contains('five')) {
      daysPerWeek = 5;
    } else if (lowerQuestion.contains('6') || lowerQuestion.contains('six')) {
      daysPerWeek = 6;
    }
    
    // Determine difficulty
    if (lowerQuestion.contains('beginner')) {
      difficulty = "beginner";
    } else if (lowerQuestion.contains('intermediate')) {
      difficulty = "intermediate";
    } else if (lowerQuestion.contains('advanced')) {
      difficulty = "advanced";
    }
    
    return await generateWorkoutPlan(
      focus: focus,
      daysPerWeek: daysPerWeek,
      difficulty: difficulty,
    );
  }

  Future<String> _recommendExercises() async {
    final exercises = await isar.exercises.where().findAll();
    
    if (exercises.isEmpty) {
      return "I don't have any exercises to recommend yet. Please add some exercises first!";
    }

    final beginnerExercises = exercises.where((e) => e.difficulty == data_enums.Difficulty.beginner).take(5).toList();
    final intermediateExercises = exercises.where((e) => e.difficulty == data_enums.Difficulty.intermediate).take(5).toList();
    
    String recommendations = "Here are some exercise recommendations:\n\n";
    
    if (beginnerExercises.isNotEmpty) {
      recommendations += "**Beginner-friendly exercises:**\n";
      for (var exercise in beginnerExercises) {
        recommendations += "• ${exercise.name} (${exercise.primaryMuscle})\n";
      }
      recommendations += "\n";
    }
    
    if (intermediateExercises.isNotEmpty) {
      recommendations += "**Intermediate exercises:**\n";
      for (var exercise in intermediateExercises) {
        recommendations += "• ${exercise.name} (${exercise.primaryMuscle})\n";
      }
    }
    
    return recommendations;
  }

  Future<String> _getWeightAdvice() async {
    final userProfile = await isar.userProfiles.get(1);
    
    if (userProfile == null) {
      return "I need your profile information to give you personalized weight advice. Please complete your profile first!";
    }

    String advice = "Based on your profile:\n\n";
    
    switch (userProfile.weightGoal) {
      case data_enums.WeightGoal.weightLoss:
        advice += "**Weight Loss Strategy:**\n";
        advice += "• Create a caloric deficit of 300-500 calories per day\n";
        advice += "• Focus on high-protein foods to preserve muscle\n";
        advice += "• Include both cardio and strength training\n";
        advice += "• Aim to lose 1-2 pounds per week for sustainable results\n";
        break;
      case data_enums.WeightGoal.weightGain:
        advice += "**Weight Gain Strategy:**\n";
        advice += "• Create a caloric surplus of 300-500 calories per day\n";
        advice += "• Prioritize protein (1.6-2.2g per kg body weight)\n";
        advice += "• Focus on compound exercises for muscle growth\n";
        advice += "• Get adequate sleep (7-9 hours) for recovery\n";
        break;
      case data_enums.WeightGoal.maintenance:
        advice += "**Weight Maintenance Strategy:**\n";
        advice += "• Match calories in with calories out\n";
        advice += "• Maintain regular exercise routine\n";
        advice += "• Focus on body composition over scale weight\n";
        advice += "• Regular strength training to preserve muscle\n";
        break;
    }
    
    return advice;
  }

  Future<String> _getRecoveryAdvice() async {
    final completedWorkouts = await isar.completedWorkouts.where().findAll();
    
    String advice = "**Recovery Best Practices:**\n\n";
    advice += "• **Sleep:** Aim for 7-9 hours of quality sleep\n";
    advice += "• **Hydration:** Drink water throughout the day\n";
    advice += "• **Stretching:** Include 10-15 minutes of stretching post-workout\n";
    advice += "• **Rest Days:** Take 1-2 rest days per week\n";
    advice += "• **Nutrition:** Eat protein and carbs within 30 minutes post-workout\n";
    advice += "• **Active Recovery:** Light walking or yoga on rest days\n";
    
    if (completedWorkouts.isNotEmpty) {
      advice += "\nBased on your workout history, make sure to vary your training intensity and give your muscles adequate time to recover between similar workouts.";
    }
    
    return advice;
  }
} 