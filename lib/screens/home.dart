import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sensor_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoke Detector'),
      ),
      body: Consumer<SensorData>(
        builder: (context, sensorData, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gas Level',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColor(sensorData.gasLevel),
                  ),
                  child: Center(
                    child: Text(
                      '${sensorData.gasLevel.toStringAsFixed(2)} ppm',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: sensorData.isConnected
                      ? sensorData.disconnect
                      : sensorData.connectToSensor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sensorData.isConnected ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(sensorData.isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColor(double gasLevel) {
    if (gasLevel < 200) return Colors.green;
    if (gasLevel < 400) return Colors.yellow;
    return Colors.red;
  }
}