import 'package:flutter/material.dart';

class AlertsHistoryPage extends StatelessWidget {
  final List<String> _mockAlerts = [
    'High gas level detected - 2023-07-30 14:30',
    'Sensor offline - 2023-07-29 09:15',
    'High gas level detected - 2023-07-28 18:45',
  ];

  AlertsHistoryPage({super.key, required List<String> alerts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts History')),
      body: ListView.builder(
        itemCount: _mockAlerts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.warning, color: Colors.yellow),
            title: Text(_mockAlerts[index]),
          );
        },
      ),
    );
  }
}