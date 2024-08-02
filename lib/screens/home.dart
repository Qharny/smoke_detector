import 'package:flutter/material.dart';
import 'package:smoketector/model/reading.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'database.dart';
import 'history.dart';
import 'remote.dart';
import 'sensor_detaol.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<WebSocketChannel> channels = [
    WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8080')),
    WebSocketChannel.connect(Uri.parse('ws://198.0.1.0:3000')),
  ];

  List<bool> isConnected = [false, false];
  List<double> gasLevels = [0.0, 0.0];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<GasReading> readings = [];
  Position? currentPosition;
  List<String> alerts = [];

  @override
  void initState() {
    super.initState();
    initNotifications();
    connectToESP32s();
    loadReadings();
    getCurrentLocation();
    loadOfflineData();
  }

  void initNotifications() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void connectToESP32s() {
    for (int i = 0; i < channels.length; i++) {
      channels[i].stream.listen(
        (data) {
          setState(() {
            isConnected[i] = true;
            gasLevels[i] = double.parse(data);
          });
          saveReading(gasLevels[i]);
          if (gasLevels[i] > 500) {
            showNotification();
            addAlert('High gas level detected: ${gasLevels[i]}');
          }
          saveOfflineData();
        },
        onError: (error) {
          setState(() {
            isConnected[i] = false;
          });
        },
        onDone: () {
          setState(() {
            isConnected[i] = false;
          });
        },
      );
    }
  }

  Future<void> saveReading(double level) async {
    final reading = GasReading(
      id: 0,
      level: level,
      timestamp: DateTime.now(),
    );
    await DatabaseHelper.instance.insertReading(reading);
    loadReadings();
  }

  Future<void> loadReadings() async {
    final loadedReadings = await DatabaseHelper.instance.getReadings();
    setState(() {
      readings = loadedReadings;
    });
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'gas_detector_channel', 'Gas Detector Notifications',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Gas Detected!',
      'High levels of gas detected. Please check your environment.',
      platformChannelSpecifics,
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void addAlert(String alert) {
    setState(() {
      alerts.add('${DateTime.now()}: $alert');
    });
  }

  Future<void> saveOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'gasLevels', gasLevels.map((e) => e.toString()).toList());
    await prefs.setStringList('alerts', alerts);
  }

  Future<void> loadOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedGasLevels = prefs.getStringList('gasLevels');
    List<String>? savedAlerts = prefs.getStringList('alerts');

    if (savedGasLevels != null) {
      setState(() {
        gasLevels = savedGasLevels.map((e) => double.parse(e)).toList();
      });
    }

    if (savedAlerts != null) {
      setState(() {
        alerts = savedAlerts;
      });
    }
  }

  Future<void> exportData() async {
    List<List<dynamic>> rows = [
      ['Timestamp', 'Gas Level'],
      ...readings.map(
          (reading) => [reading.timestamp.toIso8601String(), reading.level]),
    ];

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/gas_readings.csv';
    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data exported to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gas Detector'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Sensor Location',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GeolocationPage(position: currentPosition)),
                );
              },
            ),
            ListTile(
              title: const Text('Remote Control',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RemoteControlPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Alerts History',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AlertsHistoryPage(alerts: alerts)),
                );
              },
            ),
            ListTile(
              title: const Text('Export Data',
                  style: TextStyle(color: Colors.white)),
              onTap: exportData,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < channels.length; i++) _buildSensorWidget(i),
          const SizedBox(height: 20),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildSensorWidget(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Sensor ${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              Icon(
                isConnected[index] ? Icons.wifi : Icons.wifi_off,
                color: isConnected[index] ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                'Gas Level: ${gasLevels[index].toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gasLevels[index] > 500 ? Colors.red : Colors.green,
                ),
                child: Center(
                  child: Text(
                    gasLevels[index] > 500 ? 'DANGER' : 'SAFE',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: readings.length.toDouble() - 1,
          minY: 0,
          maxY: readings.isEmpty
              ? 1000
              : readings.map((r) => r.level).reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: readings.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.level);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var channel in channels) {
      channel.sink.close();
    }
    super.dispose();
  }
}
