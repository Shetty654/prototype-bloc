import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';


import 'package:CAPO/presentation/views/home/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../../../../blocs/home/chart/chart_bloc.dart';
import '../../../../blocs/home/dashboard/dashboard_bloc.dart';
import '../../../../blocs/home/home_bloc.dart';
import '../../../../data/models/dashboard.dart';

class Home extends StatefulWidget {
  final String projectName;
  const Home({super.key, required this.projectName});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0; // Index of currently selected dashboard
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<Dashboard> _dashboards = []; // All dashboards for the project

  @override
  void initState() {
    super.initState();
    _loadUsernameAndDispatch(); // Load username from secure storage and dispatch fetch event
  }

  // Loads stored username and fetches dashboards for user+project
  Future<void> _loadUsernameAndDispatch() async {
    final username = await _secureStorage.read(key: 'username');
    if (username != null) {
      BlocProvider.of<DashboardBloc>(context).add(
        DashboardsFetch(
          projectName: widget.projectName,
          username: username,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: Column(
        children: [
          // Build UI based on dashboard loading state
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardsLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardsLoadFailure) {
                return Center(child: Text('Failed to load dashboards: ${state.message}'));
              } else if (state is DashboardsLoadSuccess) {
                final dashboards = state.dashboards;

                if (dashboards.isEmpty) {
                  return const Center(child: Text('No dashboard configured.'));
                }

                // Initialize dashboards only once
                if (_dashboards.isEmpty) {
                  _dashboards = dashboards;
                  _index = 0;

                  // Dispatch selected dashboard to HomeBloc
                  BlocProvider.of<HomeBloc>(context).add(
                    DashboardSelected(selectedDashboard: _dashboards[_index]),
                  );
                }
              }

              return const SizedBox(); // Placeholder for unknown or initial state
            },
          ),

          // Listen for dashboard selection → trigger chart loading
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is DashboardUpdated) {
                BlocProvider.of<ChartBloc>(context).add(
                  ChartGroupSelected(selectedDashboard: state.dashboard),
                );
              }
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                if (homeState is! DashboardUpdated) {
                  return const SizedBox(); // Don't show chart if dashboard not selected
                }

                return BlocConsumer<ChartBloc, ChartState>(
                  listener: (context, chartState) {
                    if (chartState is ChartLoadFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(chartState.message)),
                      );
                    }
                  },
                  builder: (context, chartState) {
                    Map<String, List<Map<String, dynamic>>> raw = {};

                    if (chartState is ChartDataUpdated) {
                      raw = chartState.raw;
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          // Chart container
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
                                child: _buildLineChart(raw, chartState),
                              ),
                            ),
                          ),

                          // Dashboard group switch buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _buildDashboardControls(),
                          ),

                          // Scrollable list of tag values
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              children: [
                                for (final entry in raw.entries)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '${entry.key}: ${entry.value.last['value']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Handles dashboard selection logic and triggers state update
  void _selectDashboard(int index) {
    setState(() {
      _index = index;
    });

    BlocProvider.of<HomeBloc>(context).add(
      DashboardSelected(selectedDashboard: _dashboards[_index]),
    );
  }

  // Builds PREV/NEXT buttons and current dashboard name display
  Widget _buildDashboardControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_dashboards.isNotEmpty) {
              final newIndex = (_index - 1 + _dashboards.length) % _dashboards.length;
              _selectDashboard(newIndex);
            }
          },
          label: const Text('PREV'),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Text(
            _dashboards[_index].group_name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            if (_dashboards.isNotEmpty) {
              final newIndex = (_index + 1) % _dashboards.length;
              _selectDashboard(newIndex);
            }
          },
          label: const Text('NEXT'),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  // Builds line chart or fallback loading/error views
  Widget _buildLineChart(Map<String, List<Map<String, dynamic>>> raw, ChartState state) {
    if (state is ChartLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    } else if (raw.isEmpty) {
      return const Center(child: Text('No data available.'));
    } else {
      return LineChartWidget(raw: raw);
    }
  }
}

