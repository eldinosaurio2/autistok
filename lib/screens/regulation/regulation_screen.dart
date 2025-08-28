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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BreathingExerciseScreen(),
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
                    builder: (context) => GroundingExerciseScreen(),
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
