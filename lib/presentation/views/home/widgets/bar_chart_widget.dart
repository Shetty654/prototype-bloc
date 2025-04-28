import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14)]),
        ],
      ),
    );
  }
}