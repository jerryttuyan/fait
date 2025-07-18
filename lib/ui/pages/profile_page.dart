import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fait/data/enums.dart'; // Use the new enums file
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/weight_entry.dart';
import 'package:fait/main.dart';
// Import for .firstWhereOrNull
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:fait/main.dart'; // For ThemeProvider

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Gender>(
                        value: _profile.gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.wc),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        isExpanded: true,
                        items: Gender.values.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (g) => setState(() => _profile.gender = g!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<ActivityLevel>(
                        value: _profile.activityLevel,
                        decoration: InputDecoration(
                          labelText: 'Activity',
                          prefixIcon: const Icon(Icons.directions_run),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        isExpanded: true,
                        items: ActivityLevel.values.map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (a) => setState(() => _profile.activityLevel = a!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WeightGoal>(
                  value: _profile.weightGoal,
                  decoration: InputDecoration(
                    labelText: 'Weight Goal',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: WeightGoal.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                  onChanged: (g) => setState(() => _profile.weightGoal = g!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightFtCtrl,
                        decoration: InputDecoration(
                          labelText: 'Height (ft)',
                          prefixIcon: const Icon(Icons.height),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightInCtrl,
                        decoration: InputDecoration(
                          labelText: '(in)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.cake_outlined),
                      label: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ThemeMode>(
                  value: themeProvider.themeMode,
                  decoration: InputDecoration(
                    labelText: 'App Theme',
                    prefixIcon: const Icon(Icons.brightness_6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Default'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      themeProvider.setThemeMode(mode);
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
