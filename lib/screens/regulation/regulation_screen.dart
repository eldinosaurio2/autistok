import 'package:flutter/material.dart';
import 'breathing_exercise_screen.dart';
import 'grounding_exercise_screen.dart';

class RegulationScreen extends StatelessWidget {
  const RegulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regulación Emocional'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BreathingExerciseScreen(),
                  ),
                );
              },
              child: const Text('Ejercicio de Respiración (7 min)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroundingExerciseScreen(),
                  ),
                );
              },
              child: const Text('Ejercicio de Grounding (3 min)'),
            ),
          ],
        ),
      ),
    );
  }
}
