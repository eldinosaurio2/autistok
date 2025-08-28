import 'dart:async';

import 'package:flutter/material.dart';

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  _BreathingExerciseState createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = "Inhala...";

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _instruction = "Mantén...");
              Future.delayed(const Duration(seconds: 4), () {
                setState(() => _instruction = "Exhala...");
                _controller.reverse();
              });
            } else if (status == AnimationStatus.dismissed) {
              setState(() => _instruction = "Inhala...");
              _controller.forward();
            }
          });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ejercicio de Respiración")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.5).animate(_controller),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _instruction,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
