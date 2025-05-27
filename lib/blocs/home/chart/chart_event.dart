part of 'chart_bloc.dart';

@immutable
sealed class ChartEvent {}

final class ChartGroupSelected extends ChartEvent{
  final Dashboard selectedDashboard;
  ChartGroupSelected({required this.selectedDashboard});
}

final class StartLiveChart extends ChartEvent{
  final Dashboard dashboard;
  StartLiveChart({required this.dashboard});
}

final class FetchHistoricalChart extends ChartEvent{
  final Dashboard dashboard;
  final String projectName;
  final int beforeTs;
  final windowSec = Constants.MAX_POINTS;
  FetchHistoricalChart({required this.dashboard, required this.beforeTs, required this.projectName});
}

final class FetchChartByDate extends ChartEvent {
  final Dashboard dashboard;
  final String projectName;
  final String date;

  FetchChartByDate({
    required this.dashboard,
    required this.projectName,
    required this.date,
  });
}

class StopLiveUpdates extends ChartEvent {}
