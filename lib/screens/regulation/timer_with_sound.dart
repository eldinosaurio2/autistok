import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class TimerWithSound extends StatefulWidget {
  final int minutes;
  final Widget child;

  const TimerWithSound({super.key, required this.minutes, required this.child});

  @override
  _TimerWithSoundState createState() => _TimerWithSoundState();
}

class _TimerWithSoundState extends State<TimerWithSound> {
  late int _remainingSeconds;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.minutes * 60;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        playSound();
      }
    });
  }

  Future<void> playSound() async {
    await _audioPlayer.play(AssetSource("audio/bell.mp3"));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text("Temporizador de Regulación")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "$minutes:$seconds",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: widget.child),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
              },
              child: const Text("Detener"),
            ),
          )
        ],
      ),
    );
  }
}
