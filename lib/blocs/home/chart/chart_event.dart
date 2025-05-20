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
  final limit = Constants.MAX_POINTS;
  final int offset;
  final String projectName;
  FetchHistoricalChart({required this.dashboard, required this.offset, required this.projectName});
}

class StopLiveUpdates extends ChartEvent {}
