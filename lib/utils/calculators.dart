import 'dart:math';
import 'package:fait/data/WorkoutData/enums.dart';

/// BMI using imperial units
double bmi({required double lb, required double inches}) =>
    703 * lb / pow(inches, 2);

/// Harris–Benedict Resting Metabolic Rate
double rmr({
  required double lb,
  required double inches,
  required int age,
  required Gender gender,
}) {
  if (gender == Gender.male) {
    return (4.38 * lb) + (14.55 * inches) - (5.08 * age) + 260;
  } else {
    return (3.35 * lb) + (15.42 * inches) - (2.31 * age) + 43;
  }
}
