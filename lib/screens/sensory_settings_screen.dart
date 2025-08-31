import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorySettingsScreen extends StatefulWidget {
  const SensorySettingsScreen({super.key});

  @override
  State<SensorySettingsScreen> createState() => _SensorySettingsScreenState();
}

class _SensorySettingsScreenState extends State<SensorySettingsScreen> {
  double _lightSensitivity = 5.0;
  double _soundSensitivity = 5.0;
  late DataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    _loadSensorySettings();
  }

  Future<void> _loadSensorySettings() async {
    final lightSensitivity = await _dataService.loadLightSensitivity();
    final soundSensitivity = await _dataService.loadSoundSensitivity();
    setState(() {
      _lightSensitivity = lightSensitivity;
      _soundSensitivity = soundSensitivity;
    });
  }

  Future<void> _saveSensorySettings() async {
    await _dataService.saveLightSensitivity(_lightSensitivity);
    await _dataService.saveSoundSensitivity(_soundSensitivity);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );

    if (_lightSensitivity > 7) {
      _showThemeSuggestionDialog();
    }
  }

  void _showThemeSuggestionDialog() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isCurrentlyDarkMode = themeNotifier.isDarkMode;

    // Change to dark mode immediately
    if (!isCurrentlyDarkMode) {
      themeNotifier.toggleTheme();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sugerencia de Tema'),
          content: const Text(
              'Hemos notado que tienes una alta sensibilidad a la luz y hemos activado el tema oscuro. ¿Quieres mantener este cambio?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No, volver al claro'),
              onPressed: () {
                // If it's currently dark mode, toggle it back to light.
                if (themeNotifier.isDarkMode) {
                  themeNotifier.toggleTheme();
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí, mantener'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Sensorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajusta tus niveles de sensibilidad a la luz y al sonido. Si tu sensibilidad a la luz alcanza un nivel de 8 o superior, la aplicación te sugerirá cambiar automáticamente al modo oscuro para mayor comodidad visual.\n\nEn el futuro, la aplicación usará esta información para adaptar la interfaz o sugerir estrategias de regulación personalizadas.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text('Sensibilidad a la luz: ${_lightSensitivity.round()}',
                style: const TextStyle(fontSize: 18)),
            Slider(
              value: _lightSensitivity,
              min: 0,
              max: 10,
              divisions: 10,
              label: _lightSensitivity.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _lightSensitivity = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Sensibilidad al sonido',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _soundSensitivity,
              min: 0,
              max: 10,
              divisions: 10,
              label: _soundSensitivity.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _soundSensitivity = value;
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveSensorySettings,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
