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
              if (state is ChartLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ChartLoadFailure) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is ChartEmpty) {
                return Center(child: Text(state.message));
              }

              if (state is ChartLiveUpdated) {
                final List<Map<String, dynamic>> newRow = state.raw;
                return Column(
                  children: [
                    Expanded(child: LiveLineChartWidget(newRow: newRow)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _pageBack,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // red color
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // smaller padding
                            textStyle: const TextStyle(fontSize: 14), // smaller font
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // small rounded corners
                            ),
                          ),
                          onPressed: () async {
                            BlocProvider.of<ChartBloc>(context).add(StopLiveUpdates());
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
                final Map<String, List<Map<String, dynamic>>> histRaw = state.raw;
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // red color
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // smaller padding
                          textStyle: const TextStyle(fontSize: 12), // smaller font
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // small rounded corners
                          ),
                        ),
                        onPressed: () {
                          BlocProvider.of<ChartBloc>(context).add(StartLiveChart(dashboard: _dash));
                        },
                        child: const Text('GO-LIVE', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Expanded(child: StaticLineChartWidget(raw: histRaw,)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _pageBack,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // red color
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // smaller padding
                            textStyle: const TextStyle(fontSize: 14), // smaller font
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // small rounded corners
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
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _pageForward,
                        ),
                      ],
                    ),
                  ],
                );
              }
              // Default fallback
              return const Center(child: Text('No chart data available'));
            }
          ),
        ),
      ),
    );
  }
}




