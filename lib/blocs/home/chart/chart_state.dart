part of 'chart_bloc.dart';

@immutable
sealed class ChartState {
  ChartState();
}

final class ChartInitial extends ChartState {
  ChartInitial(): super();
}

class ChartLoadInProgress extends ChartState {}

class ChartLiveUpdated extends ChartState {
  final Map<String, List<Map<String, dynamic>>> raw;
  ChartLiveUpdated({required this.raw});
}

class ChartHistoricalUpdated extends ChartState {
  final Map<String, List<Map<String, dynamic>>> raw;
  final int offset; // so UI knows “which page” it is
  ChartHistoricalUpdated({required this.raw, required this.offset});
}


class ChartLoadFailure extends ChartState {
  final String message;
  ChartLoadFailure({required this.message});
}

class ChartLiveStopped extends ChartState {}