import 'package:flutter/material.dart';

class TagValuesList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> raw;

  const TagValuesList({Key? key, required this.raw}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (raw.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: raw.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final entry = raw.entries.elementAt(index);
        final tag = entry.key;
        var latestValue = entry.value.last['value'];
        String displayValue;
        if (latestValue is num) {
          displayValue = latestValue.toStringAsFixed(3);
        } else {
          displayValue = latestValue?.toString() ?? 'N/A';
        }
        return ListTile(
          title: Text(tag),
          trailing: Text(
            '$displayValue',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}