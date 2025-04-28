import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StompClient _stompClient;
  List<FlSpot> _chartData = [];
  double _baseTs = 0;

  @override
  void initState() {
    super.initState();
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://192.168.1.33:8080/ws',
        onConnect: _onStompConnect,
        onDebugMessage: (msg) => print('[STOMP] $msg'),
      ),
    )..activate();
  }

  void _onStompConnect(StompFrame frame) {
    print('✅ STOMP connected, subscribing to /topic/chart/11testdb11gr1');

    _stompClient.subscribe(
      destination: '/topic/chart/1second',
      callback: (StompFrame f) {
        if (f.body != null) {
          final rows = jsonDecode(f.body!) as List<dynamic>;
          if (rows.isEmpty) return;

          _baseTs = DateTime.parse(rows.first['timestamp'])
              .millisecondsSinceEpoch
              .toDouble();

          final spots = rows.map<FlSpot>((row) {
            final ts = DateTime.parse(row['timestamp'])
                .millisecondsSinceEpoch
                .toDouble();
            final val = (row['value'] as num).toDouble();
            return FlSpot(ts - _baseTs, val); // normalized
          }).toList();

          print('📈 Got ${spots.length} points');

          setState(() {
            _chartData = spots;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _dashboardCard(
                title: 'Live Trend',
                child: _chartData.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : LineChartWidget(chartData: _chartData),
                height: 200,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _dashboardCard(
                      title: 'Bar Chart',
                      child: const BarChartPlaceholder(),
                      height: 220,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _dashboardCard(
                      title: 'Pie Chart',
                      child: const PieChartPlaceholder(),
                      height: 160,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  SimpleCard("Tags", Icons.tag),
                  SimpleCard("Reports", Icons.description),
                  SimpleCard("Alarms", Icons.warning_amber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required Widget child,
    double height = 160,
  }) =>
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(height: height, child: child),
            ],
          ),
        ),
      );
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> chartData;
  const LineChartWidget({Key? key, required this.chartData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: chartData.isNotEmpty ? chartData.last.x : 1,
        minY: minY - 1,
        maxY: maxY + 1,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            color: Colors.indigo,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class BarChartPlaceholder extends StatelessWidget {
  const BarChartPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bar Chart'));
  }
}

class PieChartPlaceholder extends StatelessWidget {
  const PieChartPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pie Chart'));
  }
}

class SimpleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const SimpleCard(this.title, this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}