
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> raw;
  const LineChartWidget({super.key, required this.raw});
  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    final List<LineSeries<Map<String, dynamic>, DateTime>> seriesList = [];

    widget.raw.forEach((tag, dataPoints) {
      if (dataPoints.isEmpty) return;

      final lastValue = dataPoints.last['value'];
      if (lastValue is! num) {
        debugPrint("Skipping non-numeric tag from chart: $tag");
        return;
      }
      seriesList.add(
        LineSeries<Map<String, dynamic>, DateTime>(
          name: tag,
          dataSource: dataPoints.where((e) => e['value'] is num || e['value'] is bool).toList(),
          xValueMapper: (row, _) => DateTime.parse(row['timestamp']),
          yValueMapper: (row, _) {
            final val = row['value'];
            if (val is bool) return val ? 1.0 : 0.0;
            if (val is num) return val.toDouble();
            return 0.0;
          },
          enableTooltip: true,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            width: 6,
            height: 6,
          ),
        ),
      );
    });

    return SfCartesianChart(
      title: ChartTitle(text: 'Live-updates'),
      legend: Legend(isVisible: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enablePinching: true,
      ),
      // Show legend with tag names
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        tooltipSettings: InteractiveTooltip(
          enable: true,
          color: Colors.black,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        dateFormat: DateFormat('HH:mm:ss'),
      ),
      series: seriesList,
    );
  }
}