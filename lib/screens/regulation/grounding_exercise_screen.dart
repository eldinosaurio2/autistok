import 'package:flutter/material.dart';
import 'timer_with_sound.dart';

class GroundingExerciseScreen extends StatefulWidget {
  const GroundingExerciseScreen({super.key});

  @override
  State<GroundingExerciseScreen> createState() =>
      _GroundingExerciseScreenState();
}

class _GroundingExerciseScreenState extends State<GroundingExerciseScreen> {
  List<bool> completed = [false, false, false, false, false];

  final List<Map<String, String>> steps = [
    {"image": "assets/icons/eye.png", "label": "Mira"},
    {"image": "assets/icons/hand.png", "label": "Toca"},
    {"image": "assets/icons/ear.png", "label": "Escucha"},
    {"image": "assets/icons/nose.png", "label": "Huele"},
    {"image": "assets/icons/mouse.png", "label": "Saborea"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ejercicio de Calma")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                completed[index] = true;
              });
              if (completed.every((c) => c)) {
                _showCompletionDialog(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: completed[index] ? Colors.green[200] : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(steps[index]["image"]!, height: 60),
                  const SizedBox(height: 10),
                  Text(steps[index]["label"]!,
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¡Bien hecho!"),
        content: const Text("Has completado el ejercicio. Respira profundo."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}

class GroundingExerciseInfoScreen extends StatelessWidget {
  const GroundingExerciseInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const groundingContent = Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Concéntrate en tus sentidos. Nombra 5 cosas que puedas ver, 4 que puedas tocar, 3 que puedas oír, 2 que puedas oler y 1 que puedas saborear.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );

    return const TimerWithSound(
      minutes: 3,
      child: groundingContent,
    );
  }
}
