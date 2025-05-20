import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:CAPO/presentation/views/home/widgets/chart_container.dart';
import 'package:CAPO/presentation/views/home/widgets/dashboard_controls.dart';
import 'package:CAPO/presentation/views/home/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../blocs/home/chart/chart_bloc.dart';
import '../../../../blocs/home/dashboard/dashboard_bloc.dart';
import '../../../../blocs/home/home_bloc.dart';
import '../../../../data/models/dashboard.dart';
import '../widgets/tag_values_list.dart';

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
  bool _isLiveMode = true;

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
        DashboardsFetch(projectName: widget.projectName, username: username),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for dashboard list load
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardsLoadSuccess && state.dashboards.isNotEmpty) {
            _dashboards = state.dashboards;
            _index = 0;
            context.read<HomeBloc>().add(
              DashboardSelected(selectedDashboard: _dashboards[0]),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardsLoadFailure) {
              return Center(child: Text('Unable to load dashboards ${state.message}'));
            }
            if (state is DashboardsLoadSuccess) {
              if (_dashboards.isEmpty) {
                return const Center(child: Text('No dashboards configured'));
              }

              // Watch ChartBloc to know whether we're live or historical,
              // and to grab the current raw data for the list.
              final chartState = context.watch<ChartBloc>().state;
              final isLive = chartState is ChartLiveUpdated;
              final rawData = chartState is ChartLiveUpdated
                  ? chartState.raw
                  : chartState is ChartHistoricalUpdated
                  ? chartState.raw
                  : <String, List<Map<String, dynamic>>>{};

              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ChartContainer(
                      dashboards: _dashboards,
                      currentIndex: _index,
                      projectName: widget.projectName,
                    ),
                  ),
                  if(isLive)
                    DashboardControls(
                      dashboards: _dashboards,
                      currentIndex: _index,
                      onDashboardChange: _selectDashboard,
                    ),
                  if (isLive)
                    Expanded(child: TagValuesList(raw: rawData)),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
  // Handles dashboard selection logic and triggers state update
  void _selectDashboard(int index) {
    setState(() {
      _index = index;
    });

    BlocProvider.of<HomeBloc>(
      context,
    ).add(DashboardSelected(selectedDashboard: _dashboards[_index]));
  }
}


