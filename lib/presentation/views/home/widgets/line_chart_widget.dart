import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
class LineChartWidget extends StatelessWidget {
  final List<FlSpot> chartData;

  const LineChartWidget({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
          ),
        ],
      ),
    );
  }
}