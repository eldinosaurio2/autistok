import 'package:autistock/models/energy_entry.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/widgets/energy_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnergyTrackerScreen extends StatefulWidget {
  const EnergyTrackerScreen({super.key});

  @override
  State<EnergyTrackerScreen> createState() => _EnergyTrackerScreenState();
}

class _EnergyTrackerScreenState extends State<EnergyTrackerScreen> {
  double _currentEnergyLevel = 5.0;
  List<EnergyEntry> _energyHistory = [];
  late DataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    _loadEnergyHistory();
  }

  Future<void> _loadEnergyHistory() async {
    final history = await _dataService.getEnergyHistory();
    setState(() {
      _energyHistory = history;
    });
  }

  Future<void> _saveEnergyEntry() async {
    final entry = EnergyEntry(
      date: DateTime.now(),
      energyLevel: _currentEnergyLevel,
    );
    await _dataService.addEnergyEntry(entry);
    _loadEnergyHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contabilidad de Energía'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '¿Cómo está tu nivel de energía?',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _currentEnergyLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: _currentEnergyLevel.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentEnergyLevel = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _saveEnergyEntry,
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Historial de Energía (últimos 7 días)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _energyHistory.isEmpty
                  ? const Center(child: Text('No hay datos de energía.'))
                  : EnergyChart(energyData: _energyHistory),
            ),
          ],
        ),
      ),
    );
  }
}
