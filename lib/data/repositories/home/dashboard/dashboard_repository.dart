import 'package:CAPO/data/providers/DashboardDataProvider.dart';

class DashboardRepository{
  final DashboardDataProvider dashboardDataProvider;

  DashboardRepository({required this.dashboardDataProvider});

  Future getAllDashboards({required String projectName, required String username}) async {
    try {
      return await dashboardDataProvider.getAllDashboards(
        projectName: projectName,
        username: username,
      );
    } catch (e) {
      print('Repository error: $e');
      rethrow;
    }
  }
}