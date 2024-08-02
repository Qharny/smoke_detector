import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';

class DataExportPage extends StatelessWidget {
  const DataExportPage({super.key});

  Future<void> _exportData() async {
    List<List<dynamic>> rows = [
      ['Timestamp', 'Gas Level'],
      ['2023-07-30 14:30', 450],
      ['2023-07-30 14:35', 470],
      ['2023-07-30 14:40', 460],
    ];

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/gas_readings.csv';
    final file = File(path);
    await file.writeAsString(csv);

    // TODO: Implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Export')),
      body: Center(
        child: ElevatedButton(
          onPressed: _exportData,
          child: const Text('Export Data'),
        ),
      ),
    );
  }
}