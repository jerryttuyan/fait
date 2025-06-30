import 'package:flutter/material.dart';
import 'package:fait/data/ProfileData/user_profile.dart';
import 'package:fait/data/StatsData/weight_entry.dart';
import 'package:fait/main.dart';
import 'package:fait/data/WorkoutData/enums.dart';

class ProfileInfoPage extends StatefulWidget {
  final String username;
  const ProfileInfoPage({super.key, required this.username});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? _birthday;
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  WeightGoal _weightGoal = WeightGoal.maintenance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.username;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _birthday ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile()
        ..name = _nameController.text
        ..gender = _gender
        ..activityLevel = _activityLevel
        ..weightGoal = _weightGoal
        ..birthday = _birthday;

      // Set height
      final ft = double.tryParse(_heightFtController.text) ?? 0;
      final inches = double.tryParse(_heightInController.text) ?? 0;
      if (ft > 0 || inches > 0) {
        profile.heightIn = (ft * 12) + inches;
      }

      // Set initial weight
      final weight = double.tryParse(_weightController.text);
      if (weight != null && weight > 0) {
        final weightEntry = WeightEntry()
          ..weight = weight
          ..date = DateTime.now();
        await isar.writeTxn(() async {
          await isar.userProfiles.put(profile);
          await isar.weightEntrys.put(weightEntry);
        });
      } else {
        await isar.writeTxn(() async {
          await isar.userProfiles.put(profile);
        });
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightFtController,
                      decoration: const InputDecoration(
                        labelText: 'Height (ft)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Feet?' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _heightInController,
                      decoration: const InputDecoration(
                        labelText: 'Height (in)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Inches?' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your weight' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthday == null
                          ? 'Select Birthday'
                          : 'Birthday: \\${_birthday!.month}/\\${_birthday!.day}/\\${_birthday!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Gender>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (g) => setState(() => _gender = g!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ActivityLevel>(
                value: _activityLevel,
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items: ActivityLevel.values
                    .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                    .toList(),
                onChanged: (a) => setState(() => _activityLevel = a!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WeightGoal>(
                value: _weightGoal,
                decoration: const InputDecoration(labelText: 'Weight Goal'),
                items: WeightGoal.values
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (w) => setState(() => _weightGoal = w!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  child: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
