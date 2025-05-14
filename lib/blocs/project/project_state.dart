part of 'project_bloc.dart';

@immutable
sealed class ProjectState {}

final class ProjectInitial extends ProjectState {}

final class ProjectListLoadSuccess extends ProjectState{
  List<String> projects;
  ProjectListLoadSuccess({required this.projects});
}

final class ProjectListLoadInProgress extends ProjectState{}

final class ProjectListLoadFailure extends ProjectState{}



