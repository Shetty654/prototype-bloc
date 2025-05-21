import 'package:CAPO/constants/constants.dart';
import 'package:CAPO/presentation/views/home/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/home/chart/chart_bloc.dart';
import '../../../../data/models/dashboard.dart';

class ChartContainer extends StatefulWidget {
  final List<Dashboard> dashboards;
  final int currentIndex;
  final String projectName;

  const ChartContainer({
    Key? key,
    required this.dashboards,
    required this.currentIndex,
    required this.projectName,
  }) : super(key: key);

  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  int? _historicalBeforeTs;
  final int _windowSec = Constants.MAX_POINTS;

  bool get _isLive => _historicalBeforeTs == null;
  Dashboard get _dash => widget.dashboards[widget.currentIndex];

  void _pageBack() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _historicalBeforeTs ??= now;
    _historicalBeforeTs = _historicalBeforeTs! - (_windowSec * 1000);

    context.read<ChartBloc>().add(StopLiveUpdates());
    context.read<ChartBloc>().add(FetchHistoricalChart(
      dashboard: _dash,
      projectName: widget.projectName,
      beforeTs: _historicalBeforeTs!,
    ));
  }


  void _pageForward() {
    if (_historicalBeforeTs == null) return;

    _historicalBeforeTs = _historicalBeforeTs! + (_windowSec * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_historicalBeforeTs! >= now) {
      _historicalBeforeTs = null;
      context.read<ChartBloc>().add(ChartGroupSelected(selectedDashboard: _dash));
    } else {
      context.read<ChartBloc>().add(FetchHistoricalChart(
        dashboard: _dash,
        projectName: widget.projectName,
        beforeTs: _historicalBeforeTs!,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: height * 0.6,
          child: BlocBuilder<ChartBloc, ChartState>(
            builder: (context, state) {
              // extract raw map in either live or historical
              final raw = state is ChartLiveUpdated
                  ? state.raw
                  : state is ChartHistoricalUpdated
                  ? state.raw
                  : <String, List<Map<String, dynamic>>>{};

              if (state is ChartLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ChartLoadFailure) {
                return Center(child: Text('Error: ${state.message}'));
              }

              return Column(
                children: [
                  // the chart
                  Expanded(child: LineChartWidget(raw: raw)),
                  const SizedBox(height: 12),
                  // back / forward arrows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        tooltip: 'Older',
                        onPressed: _pageBack,
                      ),
                      IconButton(
                        icon: Icon(
                          _isLive ? Icons.rss_feed : Icons.arrow_forward_ios,
                        ),
                        tooltip: _isLive ? 'Live' : 'Newer',
                        onPressed: _pageForward,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
// Builds line chart or fallback loading/error views
Widget _buildLineChart(
    Map<String, List<Map<String, dynamic>>> raw,
    ChartState state,
    ) {
  if (state is ChartLoadInProgress) {
    return const Center(child: CircularProgressIndicator());
  } else if (raw.isEmpty) {
    return const Center(child: Text('No data available.'));
  } else {
    return LineChartWidget(raw: raw);
  }
}



