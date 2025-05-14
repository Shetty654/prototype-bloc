import 'dart:convert';
import 'dart:io';

import 'package:CAPO/constants/constants.dart';
import 'package:http/http.dart' as http;

class ProjectDataProvider{
  Future getAllProjects() async {
      final url = Uri.parse('${Constants.BASE_URL}user/projects');
      final response = await http.get(url);
      if(response.statusCode == HttpStatus.ok){
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<String>();
      }else{
        throw Exception('Failed to load projects');
      }
  }
}