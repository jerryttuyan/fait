// Enumerating groups of variables.
enum WeightGoal { weightLoss, weightGain, maintenance }
enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extraActive }
enum Gender { male, female }

//Calculate BMI and RMR
class WeightManagementCalculator {
  static double calculateBMI(double weightKg, double heightM) {
    return weightKg / (heightM * heightM);
  }

  static double calculateRMR(double weightKg, double heightCm, int age, Gender gender) {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // Calculate Total Daily Energy Expenditure
  static double calculateTDEE(double rmr, ActivityLevel activityLevel) {
    Map<ActivityLevel, double> multipliers = {
      ActivityLevel.sedentary: 1.2,
      ActivityLevel.lightlyActive: 1.375,
      ActivityLevel.moderatelyActive: 1.55,
      ActivityLevel.veryActive: 1.725,
      ActivityLevel.extraActive: 1.9,
    };
    return rmr * multipliers[activityLevel]!;
  }

  // Get recommended caloric count for each option
  static double calculateTargetCalories(double tdee, WeightGoal goal) {
    switch (goal) {
      case WeightGoal.weightLoss:
        return tdee - 500;
      case WeightGoal.weightGain:
        return tdee + 500;
      case WeightGoal.maintenance:
        return tdee;
    }
  }
// get macros (fat, protein, carbs)
  static MacronutrientNeeds calculateMacros(double targetCalories, double weightKg, WeightGoal goal) {
    double proteinGrams;
    switch (goal) {
      case WeightGoal.weightLoss:
        proteinGrams = weightKg * 2.2;
        break;
      case WeightGoal.weightGain:
        proteinGrams = weightKg * 2.0;
        break;
      case WeightGoal.maintenance:
        proteinGrams = weightKg * 1.8;
        break;
    }

    double fatGrams = (targetCalories * 0.275) / 9;
    double remainingCalories = targetCalories - (proteinGrams * 4) - (fatGrams * 9);
    double carbGrams = remainingCalories / 4;

    return MacronutrientNeeds(
      protein: proteinGrams,
      fat: fatGrams,
      carbs: carbGrams,
      calories: targetCalories,
    );
  }
}
// Data model that holds requierements calculated
class MacronutrientNeeds {
  final double protein;
  final double fat;
  final double carbs;
  final double calories;

  MacronutrientNeeds({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.calories,
  });
}
// Container for all calculated health data
class WeightManagementResult {
  final double bmi;
  final String bmiCategory;
  final double rmr;
  final double tdee;
  final MacronutrientNeeds macros;
  final WeightGoal goal;

  WeightManagementResult({
    required this.bmi,
    required this.bmiCategory,
    required this.rmr,
    required this.tdee,
    required this.macros,
    required this.goal,
  });

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}
// Take input
WeightManagementResult getWeightManagementPlan({
  required double weightKg,
  required double heightCm,
  required int age,
  required Gender gender,
  required ActivityLevel activityLevel,
  required WeightGoal goal,
}) {
  // Run calculations
  double heightM = heightCm / 100;
  double bmi = WeightManagementCalculator.calculateBMI(weightKg, heightM);
  String bmiCategory = WeightManagementResult.getBMICategory(bmi);

  double rmr = WeightManagementCalculator.calculateRMR(weightKg, heightCm, age, gender);
  double tdee = WeightManagementCalculator.calculateTDEE(rmr, activityLevel);
  double targetCalories = WeightManagementCalculator.calculateTargetCalories(tdee, goal);

  MacronutrientNeeds macros = WeightManagementCalculator.calculateMacros(targetCalories, weightKg, goal);

// Return results
  return WeightManagementResult(
    bmi: bmi,
    bmiCategory: bmiCategory,
    rmr: rmr,
    tdee: tdee,
    macros: macros,
    goal: goal,
  );
}
