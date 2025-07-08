enum Gender { male, female }

enum WeightGoal { weightLoss, weightGain, maintenance }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive;

  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Not Active';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extraActive:
        return 'Always Active';
    }
  }
}

enum Difficulty { beginner, intermediate, advanced }

enum PushPullType { push, pull, legs, fullBody, cardio, other }

enum EquipmentType {
  barbell,
  dumbbell,
  machine,
  bodyweight,
  cable,
  kettlebell,
  band,
  other,
}

enum MuscleGroup {
  abs,
  back,
  biceps,
  chest,
  glutes,
  hamstrings,
  quadriceps,
  shoulders,
  triceps,
  lowerBack,
  cardio,
}

enum SplitType { push, pull, legs, fullBody, upper, lower, other }

extension GenderDisplayName on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }
}

extension WeightGoalDisplayName on WeightGoal {
  String get displayName {
    switch (this) {
      case WeightGoal.weightLoss:
        return 'Weight Loss';
      case WeightGoal.weightGain:
        return 'Weight Gain';
      case WeightGoal.maintenance:
        return 'Maintenance';
    }
  }
}
