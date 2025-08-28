import 'package:autistock/app_theme.dart';
import 'package:autistock/screens/emergency_contact_screen.dart';
import 'package:autistock/screens/home_screen.dart';
import 'package:autistock/screens/mood_tracker_screen.dart';
import 'package:autistock/screens/regulation/regulation_screen.dart';
import 'package:autistock/screens/rewards_screen.dart';
import 'package:autistock/screens/settings_screen.dart';
import 'package:autistock/screens/user_manual_screen.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/notification_service.dart';
import 'package:autistock/services/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataService = DataService();
  await NotificationService().init();
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>.value(value: dataService),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => RewardService(dataService)),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: const AutiStockApp(),
    ),
  );
}

class AutiStockApp extends StatelessWidget {
  const AutiStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'AutiStock',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeNotifier.textScaleFactor)),
              child: child!,
            );
          },
          home: const MainScreen(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
            '/emergency': (context) => const EmergencyContactScreen(),
            '/manual': (context) => const UserManualScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onNavigateToPage: _onItemTapped),
      const MoodTrackerScreen(),
      const RewardsScreen(),
      const EmergencyContactScreen(),
    ];
  }

  static const List<String> _titles = <String>[
    'Inicio',
    'Registro de Ánimo',
    'Recompensas',
    'Contacto de Emergencia',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              exit(0);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Autistok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manual de Usuario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manual');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied),
            label: 'Ánimo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Recompensas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_emergency),
            label: 'Emergencia',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
