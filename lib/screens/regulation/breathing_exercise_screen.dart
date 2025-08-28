import 'package:flutter/material.dart';
import 'timer_with_sound.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breathingAnimation = Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -100 * (1 - _animation.value)),
            child: child,
          );
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Center(
            child: Text(
              _controller.status == AnimationStatus.forward ||
                      _controller.status == AnimationStatus.completed
                  ? 'Inhala'
                  : 'Exhala',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );

    return TimerWithSound(
      minutes: 7,
      child: breathingAnimation,
    );
  }
}
