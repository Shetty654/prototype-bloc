import 'package:flutter/material.dart';

class DashboardControls extends StatelessWidget {
  final List<
      dynamic> dashboards; // Replace `dynamic` with your actual Dashboard model
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  textStyle: const TextStyle(fontSize: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text('PREV'),
                onPressed: () {
                  final newIndex = (currentIndex - 1 + dashboards.length) %
                      dashboards.length;
                  onDashboardChange(newIndex);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Text(
              dashboards[currentIndex].group_name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  textStyle: const TextStyle(fontSize: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text('NEXT'),
                onPressed: () {
                  final newIndex = (currentIndex + 1) % dashboards.length;
                  onDashboardChange(newIndex);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}