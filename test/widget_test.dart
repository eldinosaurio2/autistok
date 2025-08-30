import 'package:autistock/main.dart';
import 'package:autistock/services/data_service.dart';
import 'package:autistock/services/reward_service.dart';
import 'package:autistock/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts and displays home screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final dataService = DataService();
    final rewardService = RewardService(dataService);
    final themeNotifier = ThemeNotifier(dataService);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
          Provider<DataService>.value(value: dataService),
          ChangeNotifierProvider<RewardService>.value(value: rewardService),
        ],
        child: const AutiStockApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the app title is displayed in the AppBar.
    expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Inicio')),
        findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final dataService = DataService();
    final rewardService = RewardService(dataService);
    final themeNotifier = ThemeNotifier(dataService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
          Provider<DataService>.value(value: dataService),
          ChangeNotifierProvider<RewardService>.value(value: rewardService),
        ],
        child: const AutiStockApp(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
