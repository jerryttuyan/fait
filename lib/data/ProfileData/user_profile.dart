import 'package:isar/isar.dart';
import '../WorkoutData/enums.dart'; // Import the new enums file

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = 1;

  String? name;
  DateTime? birthday;
  double? heightIn;

  @enumerated
  Gender gender = Gender.male;

  @enumerated
  ActivityLevel activityLevel = ActivityLevel.sedentary;

  @enumerated
  WeightGoal weightGoal = WeightGoal.maintenance;

  @ignore
  int? get age {
    if (birthday == null) return null;
    final today = DateTime.now();
    int age = today.year - birthday!.year;
    if (today.month < birthday!.month ||
        (today.month == birthday!.month && today.day < birthday!.day)) {
      age--;
    }
    return age;
  }
}
