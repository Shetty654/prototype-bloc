import 'dart:convert';

class Dashboard{
  final String id;
  final String group_name;
  final String widget_type;

  Dashboard({
    required this.id,
    required this.group_name,
    required this.widget_type,
  });

  /// Create a Dashboard instance from a JSON map
  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['id'] as String,
      widget_type: json['widget_type'] as String,
      group_name: json['group_name'] as String,
    );
  }

  /// Convert a Dashboard instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': group_name,
      'widget_type': widget_type,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}