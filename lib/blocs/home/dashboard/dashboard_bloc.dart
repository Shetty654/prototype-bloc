import 'dart:async';

import 'package:CAPO/data/repositories/home/dashboard/dashboard_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/dashboard.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository}) : super(DashboardInitial()) {
    // Registering the event handler inside the constructor
    on<DashboardsFetch>(_onDashboardFetch);
  }

  FutureOr<void> _onDashboardFetch(
      DashboardsFetch event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardsLoadInProgress());
    try {
      final dashboards = await dashboardRepository.getAllDashboards(
        projectName: event.projectName,
        username: event.username,
      );
      emit(DashboardsLoadSuccess(dashboards: dashboards));
    } catch (e) {
      emit(DashboardsLoadFailure(message: e.toString()));
    }
  }
}