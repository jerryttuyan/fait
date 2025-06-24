import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fait/data/enums.dart'; // Use the new enums file
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/weight_entry.dart';
import 'package:fait/main.dart';
// Import for .firstWhereOrNull
import 'package:flutter/foundation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _heightFtCtrl = TextEditingController();
  final _heightInCtrl = TextEditingController();
  DateTime? _birthday;
  UserProfile _profile = UserProfile();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await isar.userProfiles.get(1);
    if (profile != null) {
      setState(() {
        _profile = profile;
        _nameCtrl.text = _profile.name ?? '';
        if (profile.heightIn != null) {
          final feet = (profile.heightIn! / 12).floor();
          final inches = (profile.heightIn! % 12).round();
          _heightFtCtrl.text = feet.toString();
          _heightInCtrl.text = inches.toString();
        }
        _birthday = _profile.birthday;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _profile.name = _nameCtrl.text;

      final ft = double.tryParse(_heightFtCtrl.text) ?? 0;
      final inches = double.tryParse(_heightInCtrl.text) ?? 0;
      if (ft > 0 || inches > 0) {
        _profile.heightIn = (ft * 12) + inches;
      } else {
        _profile.heightIn = null;
      }

      _profile.birthday = _birthday;
      // Gender, Activity Level, and Weight Goal are updated by their respective DropdownButtons

      await isar.writeTxn(() async {
        await isar.userProfiles.put(_profile);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved!')),
      );
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Gender>(
              value: _profile.gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
              onChanged: (g) => setState(() => _profile.gender = g!),
            ),
            const SizedBox(height: 16),
            // New Dropdowns for Activity and Goal
            DropdownButtonFormField<ActivityLevel>(
              value: _profile.activityLevel,
              decoration: const InputDecoration(labelText: 'Activity Level'),
              items: ActivityLevel.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (a) => setState(() => _profile.activityLevel = a!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WeightGoal>(
              value: _profile.weightGoal,
              decoration: const InputDecoration(labelText: 'Weight Goal'),
              items: WeightGoal.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
              onChanged: (g) => setState(() => _profile.weightGoal = g!),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightFtCtrl,
                    decoration: const InputDecoration(labelText: 'Height (ft)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightInCtrl,
                    decoration: const InputDecoration(labelText: '(in)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _birthday == null ? 'No birthday selected' : 'Birthday: ${DateFormat.yMMMd().format(_birthday!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
            if (kDebugMode)
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Reset App Data"),
                      content: const Text("This will erase your saved profile. Are you sure?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Reset")),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await isar.writeTxn(() async {
                      await isar.userProfiles.clear();
                      await isar.weightEntrys.clear();
                    });
                    setState(() {
                      _profile = UserProfile();
                      _nameCtrl.clear();
                      _heightFtCtrl.clear();
                      _heightInCtrl.clear();
                      _birthday = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("App data reset.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reset App (Dev Only)"),
              ),
          ],
        ),
      ),
    );
  }
}
