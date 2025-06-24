// lib/ui/pages/landing_page.dart

import 'package:flutter/material.dart';
import 'package:fait/ui/pages/main_screen.dart'; // Import MainScreen to navigate to it

class FitnessAppLandingPage extends StatelessWidget {
  const FitnessAppLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body directly applies the gradient for a distinct look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100, // Light blue for the top
              Colors.blue.shade400, // Deeper blue towards the bottom
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo/Icon
                Icon(
                  Icons.fitness_center, // A relevant icon for a fitness app
                  size: 100,
                  color: Colors.blue.shade900,
                ),
                const SizedBox(height: 30),
                // App Title
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
                // App Tagline/Description
                Text(
                  'Your personal guide to a healthier and stronger you. Track progress, set goals, and stay motivated!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue.shade800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 50),
                // Call to Action Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the MainScreen when the button is pressed
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor:
                        Colors.blue.shade700, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18,
                    ),
                    elevation: 5, // Shadow effect
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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
