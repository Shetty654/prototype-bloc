import 'package:CAPO/data/providers/ProjectDataProvider.dart';

class ProjectRepository{
  final ProjectDataProvider projectDataProvider;
  ProjectRepository({required this.projectDataProvider});

  Future getAllProjects() async {
    return await projectDataProvider.getAllProjects();
  }
}