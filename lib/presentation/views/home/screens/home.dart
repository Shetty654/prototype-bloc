import 'dart:async';
import 'dart:convert';

import 'package:CAPO/presentation/views/home/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../../blocs/Home/Chart/chart_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: BlocConsumer<ChartBloc, ChartState>(
        listener: (context, state) {
          if (state is ChartLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          Map<String, List<Map<String, dynamic>>> raw = {};

          if (state is ChartDataUpdated) {
            raw = state.raw;
          }

          return Column(
            children: [
              SizedBox(
                height: height * 0.45,
                child: Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildLineChart(raw, state),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final entry in raw.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: ${entry.value.last['value']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildLineChart(Map<String, List<Map<String, dynamic>>> raw, ChartState state) {
  if (state is ChartLoadInProgress) {
    return const Center(child: CircularProgressIndicator());
  } else if (raw.isEmpty) {
    return const Center(child: Text('No data available.'));
  } else {
    return LineChartWidget(raw: raw);
  }
}

// class BarChartPlaceholder extends StatelessWidget {
//   const BarChartPlaceholder({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Bar Chart'));
//   }
// }
//
// class PieChartPlaceholder extends StatelessWidget {
//   const PieChartPlaceholder({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Pie Chart'));
//   }
// }
//
// class SimpleCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   const SimpleCard(this.title, this.icon, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 110,
//       height: 110,
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 30, color: Colors.indigo),
//             const SizedBox(height: 8),
//             Text(title, style: const TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }
