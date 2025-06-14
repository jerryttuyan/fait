import 'package:flutter/material.dart';
import 'calculators.dart';

class BmiRmrPage extends StatefulWidget {
  const BmiRmrPage({super.key});
  @override
  State<BmiRmrPage> createState() => _BmiRmrPageState();
}

class _BmiRmrPageState extends State<BmiRmrPage> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl    = TextEditingController();
  Gender _gender = Gender.male;

  double? _bmi, _rmr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _numField('Weight (lb)', _weightCtrl),
            _numField('Height (in)', _heightCtrl),
            _numField('Age (yrs)',  _ageCtrl),
            DropdownButton<Gender>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: Gender.male,   child: Text('Male')),
                DropdownMenuItem(value: Gender.female, child: Text('Female')),
              ],
              onChanged: (g) => setState(() => _gender = g!),
            ),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            if (_bmi != null) Text('BMI: ${_bmi!.toStringAsFixed(1)}'),
            if (_rmr != null) Text('RMR: ${_rmr!.round()} kcal/day'),
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController c) =>
      TextField(controller: c, decoration: InputDecoration(labelText: label), keyboardType: TextInputType.number);

  void _calculate() {
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    final a = int.tryParse(_ageCtrl.text);
    if (w == null || h == null || a == null) return;

    setState(() {
      _bmi = bmi(lb: w, inches: h);
      _rmr = rmr(lb: w, inches: h, age: a, gender: _gender);
    });
  }
}