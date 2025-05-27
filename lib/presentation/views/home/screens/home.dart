import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:CAPO/presentation/views/home/widgets/chart_container.dart';
import 'package:CAPO/presentation/views/home/widgets/dashboard_controls.dart';
import 'package:CAPO/presentation/views/home/widgets/static_line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../blocs/home/chart/chart_bloc.dart';
import '../../../../blocs/home/dashboard/dashboard_bloc.dart';
import '../../../../blocs/home/home_bloc.dart';
import '../../../../constants/constants.dart';
import '../../../../data/models/dashboard.dart';
import '../widgets/tag_values_list.dart';

class Home extends StatefulWidget {
  final String projectName;

  const Home({Key? key, required this.projectName}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _secureStorage = FlutterSecureStorage();
  List<Dashboard> _dashboards = [];
  int _currentIndex = 0;

  /// Our running buffer of up to MAX_POINTS per tag
  final Map<String, List<Map<String, dynamic>>> _buffers = {};

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    final username = await _secureStorage.read(key: 'username');
    if (username != null) {
      context.read<DashboardBloc>().add(
        DashboardsFetch(
          projectName: widget.projectName,
          username: username,
        ),
      );
    }
  }

  void _selectDashboard(int newIndex) {
    setState(() => _currentIndex = newIndex);
    context.read<HomeBloc>().add(
      DashboardSelected(selectedDashboard: _dashboards[newIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardsLoadSuccess && state.dashboards.isNotEmpty) {
            _dashboards = state.dashboards;
            _currentIndex = 0;
            context.read<HomeBloc>().add(
              DashboardSelected(selectedDashboard: _dashboards[0]),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashState) {
            if (dashState is DashboardsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (dashState is DashboardsLoadFailure) {
              return Center(child: Text('Failed to load dashboards: ${dashState.message}'));
            }
            if (dashState is DashboardsLoadSuccess && _dashboards.isNotEmpty) {
              final chartState = context.watch<ChartBloc>().state;
              final isLive = chartState is ChartLiveUpdated;

              // 1) If live, buffer each new row up to MAX_POINTS
              if (isLive) {
                for (final row in (chartState as ChartLiveUpdated).raw) {
                  final tag = row['custom_name'] as String? ?? '';
                  if (tag.isEmpty) continue;
                  final buf = _buffers.putIfAbsent(tag, () => []);
                  buf.add(row);
                  if (buf.length > Constants.MAX_POINTS) buf.removeAt(0);
                }
              } else {
                // leaving live mode: clear buffer
                _buffers.clear();
              }

              return Column(
                children: [
                  // Chart area
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ChartContainer(
                      dashboards: _dashboards,
                      currentIndex: _currentIndex,
                      projectName: widget.projectName,
                    ),
                  ),

                  // Only in live mode show controls + latest-values list
                  if (isLive) ...[
                    DashboardControls(
                      dashboards: _dashboards,
                      currentIndex: _currentIndex,
                      onDashboardChange: _selectDashboard,
                    ),
                    Expanded(
                      child: TagValuesList(raw: _buffers),
                    ),
                  ],
                ],
              );
            }

            return const Center(child: Text('No dashboards available'));
          },
        ),
      ),
    );
  }
}


