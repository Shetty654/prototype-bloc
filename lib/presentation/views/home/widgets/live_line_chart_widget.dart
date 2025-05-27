import 'package:CAPO/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
class LiveLineChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> newRow;

  const LiveLineChartWidget({Key? key, required this.newRow}) : super(key: key);

  @override
  State<LiveLineChartWidget> createState() => _LiveLineChartWidgetState();
}

class _LiveLineChartWidgetState extends State<LiveLineChartWidget> {

  late final Map<String, List<Map<String, dynamic>>> _buffers;
  final Map<String, ChartSeriesController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _buffers = {};
  }

  @override
  void didUpdateWidget(covariant LiveLineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final row in widget.newRow) {
      final tag = row['custom_name'];
      final timestamp = row['timestamp'];
      final value = row['value'];

      if (tag == null || timestamp == null || value == null) continue;

      if (value is! num) {
        debugPrint("Skipping non-numeric tag from chart: $tag");
        continue;
      }

      _buffers.putIfAbsent(tag, () => []);
      final buffer = _buffers[tag]!;

      buffer.add({'timestamp': timestamp, 'value': value});
      int? removedIndex;

      if (buffer.length > Constants.MAX_POINTS) {
        buffer.removeAt(0);
        removedIndex = 0;
      }

      final controller = _controllers[tag];
      if (controller != null) {
        if (removedIndex != null) {
          controller.updateDataSource(
            addedDataIndex: buffer.length - 1,
            removedDataIndex: removedIndex,
          );
        } else {
          controller.updateDataSource(
            addedDataIndex: buffer.length - 1,
          );
        }
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: Legend(isVisible: true),

      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enablePinching: true,
      ),
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        dateFormat: DateFormat('mm:ss'),
      ),
      series: _buffers.entries.map((entry) {
        final tag = entry.key;
        final data = entry.value;

        return LineSeries<Map<String, dynamic>, DateTime>(
          name: tag,
          dataSource: data,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            width: 6,
            height: 6,
          ),
          xValueMapper: (r, _) => DateTime.parse(r['timestamp']),
          yValueMapper: (r, _) => (r['value'] as num).toDouble(),
          onRendererCreated: (controller) {
            _controllers[tag] ??= controller;
          },
        );
      }).toList(),
    );
  }
}
