import 'package:flutter/material.dart';

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({super.key});

  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  bool _isSensorOn = true;
  double _sensitivity = 50.0;

  void _toggleSensor() {
    setState(() {
      _isSensorOn = !_isSensorOn;
    });
    // TODO: Implement actual sensor control logic
  }

  void _updateSensitivity(double value) {
    setState(() {
      _sensitivity = value;
    });
    // TODO: Implement actual sensitivity adjustment logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Control')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Switch(
              value: _isSensorOn,
              onChanged: (value) => _toggleSensor(),
            ),
            Text('Sensor is ${_isSensorOn ? 'ON' : 'OFF'}'),
            const SizedBox(height: 20),
            const Text('Sensitivity'),
            Slider(
              value: _sensitivity,
              min: 0,
              max: 100,
              divisions: 100,
              label: _sensitivity.round().toString(),
              onChanged: _updateSensitivity,
            ),
          ],
        ),
      ),
    );
  }
}