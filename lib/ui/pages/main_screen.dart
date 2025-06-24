import 'package:flutter/material.dart';
import 'bmi_rmr_page.dart';
import 'macros_page.dart'; // Import the new page
import 'profile_page.dart';
import 'weight_tracking_page.dart';
import 'exercise_catalog_page.dart';
import 'workouts_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    BmiRmrPage(),
    MacrosPage(), // Add the new page
    WeightTrackingPage(),
    WorkoutsPage(),
    ProfilePage(),
  ];

  static const List<String> _pageTitles = <String>[
    'BMI & RMR',
    'Macronutrient Plan', // Add its title
    'Weight Tracker',
    'Workouts',
    'My Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // When you have 4+ items, you must set the type to fixed.
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'BMI/RMR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Macros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight_outlined),
            activeIcon: Icon(Icons.monitor_weight),
            label: 'Weight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
