import 'package:autistock/models/mood_entry.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_chart.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  MoodTrackerScreenState createState() => MoodTrackerScreenState();
}

class MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<MoodEntry> _moodHistory = [];
  String _selectedMood = 'Feliz';
  final List<String> _availableActivities = [
    'Ejercicio',
    'Socializar',
    'Trabajo',
    'Estudio',
    'Hobby',
    'Relajación'
  ];
  final List<String> _selectedActivities = [];
  String _chartType = 'line';

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final entries = await dataService.getAllMoods();
    if (mounted) {
      setState(() {
        _moodHistory = entries;
      });
    }
  }

  String _getTimeOfDay(DateTime date) {
    if (date.hour >= 5 && date.hour < 12) {
      return 'Morning';
    } else if (date.hour >= 12 && date.hour < 18) {
      return 'Afternoon';
    } else {
      return 'Night';
    }
  }

  Future<void> _saveMoodEntry() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final rewardService = Provider.of<RewardService>(context, listen: false);
    final now = DateTime.now();

    final newEntry = MoodEntry(
      date: now,
      mood: _selectedMood,
      activities: _selectedActivities,
      timeOfDay: _getTimeOfDay(now),
    );

    await dataService.saveMood(newEntry);
    final allEntries = await dataService.getAllMoods();
    rewardService.checkAndUnlockRewards(allEntries);

    if (mounted) {
      _loadMoodHistory();
      setState(() {
        _selectedActivities.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodSelector(),
                  const SizedBox(height: 24),
                  _buildActivitySelector(),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _buildChartTypeMenu(),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monitoriza',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'tu estado de ánimo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      onSelected: (String result) {
        setState(() {
          _chartType = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'line',
          child: Text('Gráfico de líneas'),
        ),
        const PopupMenuItem<String>(
          value: 'bar',
          child: Text('Gráfico de barras'),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cómo te sientes actualmente?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12.0, // Espacio horizontal entre botones
          runSpacing: 12.0, // Espacio vertical entre filas de botones
          alignment: WrapAlignment.center,
          children: [
            _buildMoodButton('Feliz', 'assets/pictogramas/feliz.png'),
            _buildMoodButton('Neutral', 'assets/pictogramas/neutral.png'),
            _buildMoodButton('Triste', 'assets/pictogramas/triste.png'),
            _buildMoodButton('Ansioso', 'assets/pictogramas/ansioso.png'),
            _buildMoodButton('Ira', 'assets/pictogramas/ira.png'),
            _buildMoodButton(
                'Preocupación', 'assets/pictogramas/preocupado.png'),
            _buildMoodButton('Asco', 'assets/pictogramas/asco.png'),
            _buildMoodButton('Miedo', 'assets/pictogramas/miedo.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodButton(String mood, String imagePath) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, height: 50),
            const SizedBox(height: 8),
            Text(
              mood,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué actividades has realizado?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _availableActivities.map((activity) {
            final isSelected = _selectedActivities.contains(activity);
            return FilterChip(
              label: Text(activity),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedActivities.add(activity);
                  } else {
                    _selectedActivities.remove(activity);
                  }
                });
              },
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildMoodChart(),
        ),
      ],
    );
  }

  Widget _buildMoodChart() {
    if (_moodHistory.isEmpty) {
      return const Center(child: Text('No mood data to display.'));
    }
    return SizedBox(
      height: 200,
      child: MoodChart(
        moodHistory: _moodHistory,
        chartType: _chartType,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _saveMoodEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Guardar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
