part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardsLoadFailure extends DashboardState{
  String message;
  DashboardsLoadFailure({required this.message});
}

final class DashboardsLoadSuccess extends DashboardState {
  final List<Dashboard> dashboards;

  DashboardsLoadSuccess({required this.dashboards})
      : assert(dashboards != null);
}

final class DashboardsLoadInProgress extends DashboardState{}




