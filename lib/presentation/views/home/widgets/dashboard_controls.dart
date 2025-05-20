import 'package:flutter/material.dart';

class DashboardControls extends StatelessWidget {
  final List<dynamic> dashboards; // Replace `dynamic` with your actual Dashboard model
  final int currentIndex;
  final void Function(int newIndex) onDashboardChange;

  const DashboardControls({
    Key? key,
    required this.dashboards,
    required this.currentIndex,
    required this.onDashboardChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dashboards.isEmpty) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          label: const Text('PREV'),
          onPressed: () {
            final newIndex =
                (currentIndex - 1 + dashboards.length) % dashboards.length;
            onDashboardChange(newIndex);
          },
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Text(
            dashboards[currentIndex].group_name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          label: const Text('NEXT'),
          onPressed: () {
            final newIndex = (currentIndex + 1) % dashboards.length;
            onDashboardChange(newIndex);
          },
        ),
      ],
    );
  }
}