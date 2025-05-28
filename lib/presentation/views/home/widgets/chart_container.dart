import 'package:CAPO/constants/constants.dart';
import 'package:CAPO/presentation/views/home/widgets/live_line_chart_widget.dart';
import 'package:CAPO/presentation/views/home/widgets/static_line_chart_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  // Timestamp to indicate the upper bound of historical data window; null means live mode
  int? _historicalBeforeTs;

  // Window size in seconds matching max points shown on chart
  final int _windowSec = Constants.MAX_POINTS;

  // Helper to check if chart is in live mode
  bool get _isLive => _historicalBeforeTs == null;

  // Current dashboard selected for chart display
  Dashboard get _dash => widget.dashboards[widget.currentIndex];

  /// Moves one window backward in historical data
  /// Updates the timestamp boundary and fetches older data
  void _pageBack() {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Initialize historical timestamp on first back navigation
    _historicalBeforeTs ??= now;

    // Move the timestamp backward by the window size (in ms)
    _historicalBeforeTs = _historicalBeforeTs! - (_windowSec * 1000);

    // Stop live updates before fetching historical data
    context.read<ChartBloc>().add(StopLiveUpdates());

    // Fetch historical data before updated timestamp
    context.read<ChartBloc>().add(FetchHistoricalChart(
      dashboard: _dash,
      projectName: widget.projectName,
      beforeTs: _historicalBeforeTs!,
    ));
  }

  /// Moves one window forward in historical data or switches to live mode if latest
  void _pageForward() {
    // If already in live mode, no action needed
    if (_historicalBeforeTs == null) return;

    // Move timestamp forward by window size (in ms)
    _historicalBeforeTs = _historicalBeforeTs! + (_windowSec * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_historicalBeforeTs! >= now) {
      // Reached or passed current time — switch back to live mode
      _historicalBeforeTs = null;
      context.read<ChartBloc>().add(ChartGroupSelected(selectedDashboard: _dash));
    } else {
      // Still historical window — fetch next batch of historical data
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
              if (state is ChartLoadInProgress) {
                // Show loading spinner while chart data is loading
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ChartLoadFailure) {
                // Show error message on failure
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is ChartEmpty) {
                // Show message if no data available for the chart
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          textStyle: const TextStyle(fontSize: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Return to live updates mode
                          context.read<ChartBloc>().add(StartLiveChart(dashboard: _dash));
                        },
                        child: const Text(
                          'GO-LIVE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // Center the message vertically
                    Expanded(
                      child: Center(
                        child: Text(state.message),
                      ),
                    ),
                  ],
                );
              }

              if (state is ChartLiveUpdated) {
                // Live data update - render live chart widget with incoming rows
                final List<Map<String, dynamic>> newRow = state.raw;
                return Column(
                  children: [
                    Expanded(child: LiveLineChartWidget(newRow: newRow)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Navigate backward in historical data
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _pageBack,
                        ),

                        // Date picker to fetch chart data by specific date
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            textStyle: const TextStyle(fontSize: 14),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            context.read<ChartBloc>().add(StopLiveUpdates());
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2021),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final formatted = DateFormat('yyyy-MM-dd').format(picked);
                              context.read<ChartBloc>().add(FetchChartByDate(
                                dashboard: _dash,
                                projectName: widget.projectName,
                                date: formatted,
                              ));
                            }
                          },
                          child: const Text('SEARCH'),
                        ),

                        // Navigate forward in historical data or return to live mode
                        IconButton(
                          color: Colors.grey,
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _pageForward,
                        ),
                      ],
                    ),
                  ],
                );
              }

              if (state is ChartHistoricalUpdated) {
                // Historical chart data loaded - render static chart widget
                final Map<String, List<Map<String, dynamic>>> histRaw = state.raw;
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          elevation: 3,
                          textStyle: const TextStyle(fontSize: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Return to live updates mode
                          context.read<ChartBloc>().add(StartLiveChart(dashboard: _dash));
                        },
                        child: const Text(
                          'GO-LIVE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(child: StaticLineChartWidget(raw: histRaw)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Navigate backward in historical data
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _pageBack,
                        ),

                        // Date picker for historical data search
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            textStyle: const TextStyle(fontSize: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2021),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final formatted = DateFormat('yyyy-MM-dd').format(picked);
                              context.read<ChartBloc>().add(FetchChartByDate(
                                dashboard: _dash,
                                projectName: widget.projectName,
                                date: formatted,
                              ));
                            }
                          },
                          child: const Text('SEARCH'),
                        ),

                        // Navigate forward in historical data or return to live mode
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _pageForward,
                        ),
                      ],
                    ),
                  ],
                );
              }

              // Default fallback UI when no chart data is available
              return const Center(child: Text('No chart data available'));
            },
          ),
        ),
      ),
    );
  }
}