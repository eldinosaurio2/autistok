import 'package:autistock/screens/calendar_screen.dart';
import 'package:autistock/screens/mood_tracker_screen.dart';
import 'package:autistock/screens/profile_screen.dart';
import 'package:autistock/screens/regulation/regulation_screen.dart';
import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
// ... existing code ...

  final Function(int) onNavigateToPage;

  const HomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DataService _dataService;
  Map<String, int> _buttonFrequencies = {};

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Perfil',
      'icon': Icons.person,
      'screen': const ProfileScreen(),
      'color': Colors.blue[100],
      'id': 'profile',
    },
    {
      'title': 'Calendario',
      'icon': Icons.calendar_today,
      'screen': const CalendarScreen(),
      'color': Colors.green[100],
      'id': 'calendar',
    },
    {
      'title': 'Registro de Ánimo',
      'icon': Icons.sentiment_satisfied,
      'screen': const MoodTrackerScreen(),
      'color': Colors.purple[100],
      'id': 'mood',
    },
    {
      'title': 'Regulación',
      'icon': Icons.self_improvement,
      'screen': const RegulationScreen(),
      'color': Colors.teal[100],
      'id': 'regulation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dataService = Provider.of<DataService>(context, listen: false);
    _loadFrequencies();
  }

  Future<void> _loadFrequencies() async {
    final frequencies = await _dataService.loadButtonFrequencies();
    if (mounted) {
      setState(() {
        _buttonFrequencies = frequencies;
        _menuItems.sort((a, b) {
          final freqA = _buttonFrequencies[a['id']] ?? 0;
          final freqB = _buttonFrequencies[b['id']] ?? 0;
          return freqB.compareTo(freqA);
        });
      });
    }
  }

  Future<void> _incrementFrequency(String buttonId) async {
    setState(() {
      _buttonFrequencies[buttonId] = (_buttonFrequencies[buttonId] ?? 0) + 1;
      _menuItems.sort((a, b) {
        final freqA = _buttonFrequencies[a['id']] ?? 0;
        final freqB = _buttonFrequencies[b['id']] ?? 0;
        return freqB.compareTo(freqA);
      });
    });
    await _dataService.saveButtonFrequencies(_buttonFrequencies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Hola, bienvenido/a a la app en desarrollo para apoyarte si eres autista como yo. Cuéntame que necesitas para mejorar el servicio. Gracias por ser parte de este proyecto',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: _menuItems.map((item) {
                  return _buildMenuButton(
                    title: item['title'],
                    icon: item['icon'],
                    screen: item['screen'],
                    color: item['color'],
                    onTap: () {
                      _incrementFrequency(item['id']);
                      if (item['id'] == 'mood') {
                        widget.onNavigateToPage(1);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => item['screen']),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required Widget screen,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: Colors.black54),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
