import 'dart:async';

import 'package:CAPO/blocs/home/chart/chart_bloc.dart';
import 'package:CAPO/blocs/home/dashboard/dashboard_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/dashboard.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DashboardBloc dashboardBloc;
  final ChartBloc chartBloc;

  HomeBloc({required this.dashboardBloc, required this.chartBloc}) : super(HomeInitial()) {
    on<DashboardSelected> (onDashboardSelected);
  }

  FutureOr<void> onDashboardSelected(DashboardSelected event, Emitter<HomeState> emit) {
    emit(DashboardUpdated(dashboard: event.selectedDashboard));
    chartBloc.add(ChartGroupSelected(selectedDashboard: event.selectedDashboard));
  }
}
