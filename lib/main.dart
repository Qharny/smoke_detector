import 'package:flutter/material.dart';
import 'package:smoke_detector/screens/splash.dart';
import 'package:provider/provider.dart';

import 'screens/notification.dart';
import 'screens/sensor_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SensorData(),
      child: MaterialApp(
        title: 'Smoke Detector',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}