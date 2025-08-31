import 'package:autistock/models/mood_entry.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/widgets/mood_chart.dart';
import 'package:autistock/services/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => MoodTrackerScreenState();
}

class MoodTrackerScreenState extends State<MoodTrackerScreen> {
  late DataService _dataService;
  late RewardService _rewardService;
  String? _selectedMood;
  final List<String> _selectedActivities = [];
  final TextEditingController _notesController = TextEditingController();
  List<MoodEntry> _moodHistory = [];
  String _chartType = 'line'; // 'line' or 'bar'

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    _rewardService = Provider.of<RewardService>(context, listen: false);
    _loadMoodHistory();
  }

  void _loadMoodHistory() async {
    final history = await _dataService.getMoodHistory();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentHistory =
        history.where((entry) => entry.date.isAfter(weekAgo)).toList();
    if (mounted) {
      setState(() {
        _moodHistory = recentHistory;
      });
    }
  }

  void _saveMoodEntry() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona un estado de ánimo.')),
      );
      return;
    }

    final newEntry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood!,
      activities: _selectedActivities,
      notes: _notesController.text,
      moodScore: _getMoodScore(_selectedMood!),
    );

    await _dataService.addMoodEntry(newEntry);

    if (!mounted) return;

    final allEntries = await _dataService.getMoodHistory();
    _rewardService.checkAndUnlockRewards(allEntries);

    _loadMoodHistory(); // Recargar el historial para actualizar el gráfico

    setState(() {
      _selectedMood = null;
      _selectedActivities.clear();
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estado de ánimo guardado con éxito.')),
    );
  }

  int _getMoodScore(String mood) {
    const moodScores = {
      // Positive
      'Feliz': 5,
      'Amor': 5,
      'Orgullo': 5,
      'Ilusión': 5,
      'Calma': 4,

      // Neutral
      'Neutral': 3,
      'Pensativo': 3,
      'Sorpresa': 3,

      // Negative
      'Preocupado': 2,
      'Ansioso': 2,
      'Triste': 2,
      'Vergüenza': 2,
      'Cansancio': 2,
      'Decepcionado': 2,
      'Miedo': 1,
      'Enojado': 1,
      'Asco': 1,
    };
    return moodScores[mood] ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Cómo te sientes hoy?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildMoodSelection(),
              const SizedBox(height: 20),
              _buildActivitySelection(),
              const SizedBox(height: 20),
              _buildNotesField(),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 20),
              _buildChartTypeSelector(),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: MoodChart(moodData: _moodHistory, chartType: _chartType),
              ),
              const SizedBox(height: 20),
              _buildMoodHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    const moods = {
      'Feliz': 'assets/pictogramas/feliz.png',
      'Triste': 'assets/pictogramas/triste.png',
      'Enojado': 'assets/pictogramas/enojado.png',
      'Sorpresa': 'assets/pictogramas/sorpresa.png',
      'Miedo': 'assets/pictogramas/miedo.png',
      'Ansioso': 'assets/pictogramas/ansioso.png',
      'Neutral': 'assets/pictogramas/neutral.png',
      'Amor': 'assets/pictogramas/amor.png',
      'Vergüenza': 'assets/pictogramas/verguenza.png',
      'Orgullo': 'assets/pictogramas/orgullo.png',
      'Cansancio': 'assets/pictogramas/cansancio.png',
      'Calma': 'assets/pictogramas/calma.png',
      'Pensativo': 'assets/pictogramas/pensativo.png',
      'Preocupado': 'assets/pictogramas/preocupado.png',
      'Asco': 'assets/pictogramas/asco.png',
      'Ilusión': 'assets/pictogramas/ilusion.png',
      'Decepcionado': 'assets/pictogramas/decepcionado.png',
    };

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: moods.entries.map((entry) {
        final isSelected = _selectedMood == entry.key;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = entry.key;
            });
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withAlpha(77)
                      : Colors.transparent,
                ),
                child: Image.asset(entry.value, width: 60, height: 60),
              ),
              const SizedBox(height: 8),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivitySelection() {
    const activities = {
      'Ejercicio': Icons.fitness_center,
      'Socializar': Icons.people,
      'Trabajo': Icons.work,
      'Ocio': Icons.videogame_asset,
      'Comida': Icons.fastfood,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Qué has hecho?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: [
            ...activities.entries.map((entry) {
              final isSelected = _selectedActivities.contains(entry.key);
              return ChoiceChip(
                label: Text(entry.key),
                avatar: Icon(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedActivities.add(entry.key);
                    } else {
                      _selectedActivities.remove(entry.key);
                    }
                  });
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: const Text('Otra'),
              onPressed: _showAddActivityDialog,
            ),
          ],
        ),
      ],
    );
  }

  void _showAddActivityDialog() async {
    final activityController = TextEditingController();
    final newActivity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Actividad'),
        content: TextField(
          controller: activityController,
          decoration: const InputDecoration(hintText: 'Nombre de la actividad'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (activityController.text.isNotEmpty) {
                Navigator.of(context).pop(activityController.text);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );

    if (newActivity != null && newActivity.isNotEmpty) {
      setState(() {
        _selectedActivities.add(newActivity);
      });
    }
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Añade una nota (opcional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveMoodEntry,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Guardar'),
    );
  }

  Widget _buildChartTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
            value: 'line', label: Text('Línea'), icon: Icon(Icons.show_chart)),
        ButtonSegment(
            value: 'bar', label: Text('Barra'), icon: Icon(Icons.bar_chart)),
      ],
      selected: {_chartType},
      onSelectionChanged: (newSelection) {
        setState(() {
          _chartType = newSelection.first;
        });
      },
    );
  }

  Widget _buildMoodHistoryList() {
    if (_moodHistory.isEmpty) {
      return const Center(child: Text('Aún no hay registros de ánimo.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial Reciente',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _moodHistory.length,
          itemBuilder: (context, index) {
            final entry = _moodHistory[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Image.asset(
                  'assets/pictogramas/${entry.mood.toLowerCase()}.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.sentiment_neutral, size: 40),
                ),
                title: Text(
                    '${entry.mood} - ${entry.date.day}/${entry.date.month}/${entry.date.year}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.activities.isNotEmpty)
                      Text('Actividades: ${entry.activities.join(', ')}'),
                    if (entry.notes?.isNotEmpty ?? false)
                      Text('Notas: ${entry.notes}'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
