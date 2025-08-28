import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:autistock/models/mood_entry.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> moodHistory;
  final String chartType;

  const MoodChart(
      {super.key, required this.moodHistory, this.chartType = 'line'});

  double _getMoodValue(String mood) {
    switch (mood) {
      case 'Feliz':
        return 5.0;
      case 'Calmo':
        return 4.0;
      case 'Neutral':
        return 3.0;
      case 'Ansioso':
        return 2.0;
      case 'Triste':
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chartType == 'bar') {
      return _buildBarChart();
    }
    return _buildLineChart();
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: moodHistory
                .asMap()
                .entries
                .map((entry) => FlSpot(
                    entry.key.toDouble(), _getMoodValue(entry.value.mood)))
                .toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: moodHistory
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: _getMoodValue(entry.value.mood),
                    color: Colors.blue,
                    width: 15,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
