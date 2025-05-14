import 'dart:async';

import 'package:CAPO/data/repositories/project/project_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;
  ProjectBloc({required this.projectRepository}) : super(ProjectInitial()) {
    on<ProjectListRequested> (_onProjectListRequested);
  }

  Future<void> _onProjectListRequested(
      ProjectListRequested event,
      Emitter<ProjectState> emit,
      ) async {
    emit(ProjectListLoadInProgress());
    try {
      final projects = await projectRepository.getAllProjects();
      emit(ProjectListLoadSuccess(projects: projects));
    } catch (e) {
      emit(ProjectListLoadFailure());
    }
  }
}
