part of 'chart_bloc.dart';

@immutable
sealed class ChartState {
  ChartState();
}

final class ChartInitial extends ChartState {
  ChartInitial(): super();
}

class ChartLoadInProgress extends ChartState {}

class ChartDataUpdated extends ChartState {
  final Map<String, List<Map<String, dynamic>>> raw;
  ChartDataUpdated({required this.raw});
}

class ChartLoadFailure extends ChartState {
  final String message;
  ChartLoadFailure({required this.message});
}