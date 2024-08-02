import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _threshold = 500;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _threshold = prefs.getDouble('threshold') ?? 500;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('threshold', _threshold);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Settings', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gas Level Threshold', style: TextStyle(fontSize: 18, color: Colors.white),),
            Slider(
              value: _threshold,
              min: 0,
              max: 1000,
              divisions: 100,
              label: _threshold.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _threshold = value;
                });
              },
              onChangeEnd: (double value) {
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text('Enable Notifications', style: TextStyle(color: Colors.white),),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}