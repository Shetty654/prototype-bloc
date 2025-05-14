part of 'chart_bloc.dart';

@immutable
sealed class ChartEvent {}

final class ChartGroupSelected extends ChartEvent{
  final Dashboard selectedDashboard;
  ChartGroupSelected({required this.selectedDashboard});
}

