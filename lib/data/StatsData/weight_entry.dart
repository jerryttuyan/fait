// lib/data/weight_entry.dart

import 'package:isar/isar.dart';

// This line is needed to generate the file that Isar needs
part 'weight_entry.g.dart';

@collection
class WeightEntry {
  Id id = Isar.autoIncrement; // Isar will automatically assign a unique ID

  late double weight;
  late DateTime date;
}