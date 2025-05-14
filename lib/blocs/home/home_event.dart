part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class DashboardSelected extends HomeEvent {
  final Dashboard selectedDashboard;
  DashboardSelected({required this.selectedDashboard});
}
