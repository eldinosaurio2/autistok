import 'package:autistock/models/energy_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnergyChart extends StatelessWidget {
  final List<EnergyEntry> energyData;

  const EnergyChart({super.key, required this.energyData});

  @override
  Widget build(BuildContext context) {
    if (energyData.isEmpty) {
      return const Center(child: Text('No hay datos de energía para mostrar.'));
    }

    final spots = energyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.energyLevel);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < energyData.length) {
                  final date = energyData[value.toInt()].date;
                  return Text(DateFormat('d/M').format(date),
                      style: const TextStyle(fontSize: 12));
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (energyData.length - 1).toDouble(),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withAlpha(77),
                  Theme.of(context).colorScheme.secondary.withAlpha(77),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
