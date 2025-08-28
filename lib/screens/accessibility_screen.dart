import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesibilidad'),
      ),
      body: ListView(
        children: const [
          // Aquí se añadirán las opciones de accesibilidad
        ],
      ),
    );
  }
}
