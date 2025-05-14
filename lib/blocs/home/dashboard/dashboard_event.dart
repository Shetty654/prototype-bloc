part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

final class DashboardsFetch extends DashboardEvent{
  final String projectName;
  final String username;
  DashboardsFetch({required this.projectName, required this.username});
}

final class DashboardSelectedEvent extends DashboardEvent{
  final Dashboard dashboard;
  DashboardSelectedEvent({required this.dashboard});
}

