import 'dart:convert';
import 'dart:io';

import 'package:CAPO/constants/constants.dart';
import 'package:http/http.dart' as http;

class ChartDataProvider{
  Future fetchHistoricalData({required String projectName, required String groupName, required int beforeTS, required int windowSec}) async {
    final uri = Uri.parse("${Constants.BASE_URL}home/historical_data").replace(
      queryParameters: {
        'projectName': projectName,
        'groupName':  groupName,
        'beforeTS':   beforeTS.toString(),
        'windowSec':   windowSec.toString(),
      },
    );
    final response = await http.get(uri);
    print('Response body: ${response.body}');
    if (response.statusCode == HttpStatus.ok) {
      final body = jsonDecode(response.body);

      final tagsData = body['tagsData'] as List;
      final Map<String, List<Map<String, dynamic>>> parsedData = {};

      for (final tagEntry in tagsData) {
        final tagName = tagEntry['custom_name'];
        final dataList = List<Map<String, dynamic>>.from(tagEntry['data']);
        parsedData[tagName] = dataList;
      }
      print(parsedData);
      return parsedData;
    } else {
      throw Exception('Failed to load historical data');
    }
  }
}