// lib/ui/pages/landing_page.dart

import 'package:flutter/material.dart';
import 'package:fait/ui/pages/main_screen.dart';
import 'package:fait/data/user_profile.dart';
import 'package:fait/data/enums.dart';
import 'package:fait/data/weight_entry.dart';
import 'package:fait/main.dart';
import 'package:intl/intl.dart';

class FitnessAppLandingPage extends StatefulWidget {
  const FitnessAppLandingPage({super.key});

  @override
  State<FitnessAppLandingPage> createState() => _FitnessAppLandingPageState();
}

class _FitnessAppLandingPageState extends State<FitnessAppLandingPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _heightFtController = TextEditingController();
  final _heightInController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Form data
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  WeightGoal _weightGoal = WeightGoal.maintenance;
  DateTime? _birthday;

  final List<String> _steps = [
    'Welcome',
    'Basic Info',
    'Physical Stats',
    'Goals & Activity',
    'Ready to Start!'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // Create user profile
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 6570)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildBasicInfoStep();
      case 2:
        return _buildPhysicalStatsStep();
      case 3:
        return _buildGoalsStep();
      case 4:
        return _buildFinalStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.fitness_center,
          size: 100,
          color: Colors.blue.shade900,
        ),
        const SizedBox(height: 30),
        Text(
          'Fait Fitness Tracker',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Your personal guide to a healthier and stronger you. Let\'s get you set up!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue.shade800,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 18,
            ),
            elevation: 5,
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<Gender>(
            value: _gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
            items: Gender.values.map((g) => DropdownMenuItem(
              value: g,
              child: Text(g.name),
            )).toList(),
            onChanged: (g) => setState(() => _gender = g!),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  _birthday == null 
                    ? 'Select Birthday' 
                    : 'Birthday: ${DateFormat.yMMMd().format(_birthday!)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  'Select Date',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStatsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Physical Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightFtController,
                decoration: InputDecoration(
                  labelText: 'Height (ft)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final ft = double.tryParse(value ?? '');
                  if (ft == null || ft <= 0 || ft > 10) {
                    return 'Enter valid feet (1-10)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _heightInController,
                decoration: InputDecoration(
                  labelText: 'Height (in)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final inches = double.tryParse(value ?? '');
                  if (inches == null || inches < 0 || inches >= 12) {
                    return 'Enter valid inches (0-11)';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _weightController,
          decoration: InputDecoration(
            labelText: 'Current Weight (lbs)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final weight = double.tryParse(value ?? '');
            if (weight == null || weight <= 0 || weight > 1000) {
              return 'Enter valid weight (1-1000 lbs)';
            }
            return null;
          },
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Goals & Activity Level',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 30),
        DropdownButtonFormField<ActivityLevel>(
          value: _activityLevel,
          decoration: InputDecoration(
            labelText: 'Activity Level',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          items: ActivityLevel.values.map((a) => DropdownMenuItem(
            value: a,
            child: Text(a.name),
          )).toList(),
          onChanged: (a) => setState(() => _activityLevel = a!),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<WeightGoal>(
          value: _weightGoal,
          decoration: InputDecoration(
            labelText: 'Weight Goal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          items: WeightGoal.values.map((g) => DropdownMenuItem(
            value: g,
            child: Text(g.name),
          )).toList(),
          onChanged: (g) => setState(() => _weightGoal = g!),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 30),
        Text(
          'You\'re all set!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Welcome to Fait, ${_nameController.text}! Your personalized fitness journey starts now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: _completeOnboarding,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 18,
            ),
            elevation: 5,
          ),
          child: const Text(
            'Start My Journey',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progress indicator
                if (_currentStep > 0) ...[
                  Row(
                    children: List.generate(_steps.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index <= _currentStep 
                              ? Colors.blue.shade700 
                              : Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Main content
                Expanded(
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
