import 'package:flutter/material.dart';

class GroundingExercise extends StatelessWidget {
  const GroundingExercise({super.key});

  final List<String> steps = const [
    "Mira 5 cosas a tu alrededor",
    "Toca 4 objetos cercanos",
    "Escucha 3 sonidos",
    "Huele 2 aromas",
    "Saborea 1 cosa"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ejercicio de Regulación")),
      body: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                steps[index],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}
