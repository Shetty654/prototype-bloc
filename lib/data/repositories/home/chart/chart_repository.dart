import 'package:CAPO/data/providers/ChartDataProvider.dart';

import '../../../models/dashboard.dart';

class ChartRepository{
  final ChartDataProvider chartDataProvider;

  ChartRepository({required this.chartDataProvider});

  Future fetchHistoricalData({required String projectName,
    required String groupName,
    required int beforeTS,
    required int windowSec,
  }) async {
    return chartDataProvider.fetchHistoricalData(projectName: projectName, groupName: groupName, beforeTS: beforeTS, windowSec: windowSec);
  }
}