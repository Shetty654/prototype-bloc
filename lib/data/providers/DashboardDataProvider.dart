import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../models/dashboard.dart';

class DashboardDataProvider {
  Future<List<Dashboard>> getAllDashboards({
    required String projectName,
    required String username,
  }) async {
    final url = Uri.parse(
      '${Constants.BASE_URL}home/dashboards?project_name=$projectName&username=$username',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('Decoded dashboard list: $jsonList');

      final dashboards = jsonList
          .map((jsonItem) {
        print('Mapping dashboard: $jsonItem');
        return Dashboard.fromJson(jsonItem);
      })
          .toList();

      print('Dashboards mapped: $dashboards');
      return dashboards;
      } else {
        throw Exception('No dashboards found.');
      }
  }
}