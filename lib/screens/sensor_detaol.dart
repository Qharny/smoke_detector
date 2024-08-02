// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class SensorDetailScreen extends StatefulWidget {
//   final int sensorId;
//   final Function(bool) onToggle;
//   final Function(double) onSensitivityChange;

//   SensorDetailScreen({
//     required this.sensorId,
//     required this.onToggle,
//     required this.onSensitivityChange,
//   });

//   @override
//   _SensorDetailScreenState createState() => _SensorDetailScreenState();
// }

// class _SensorDetailScreenState extends State<SensorDetailScreen> {
//   bool isOn = true;
//   double sensitivity = 500;
//   Position? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied');
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _currentPosition = position;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sensor ${widget.sensorId} Details'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Sensor Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Switch(
//               value: isOn,
//               onChanged: (value) {
//                 setState(() {
//                   isOn = value;
//                 });
//                 widget.onToggle(value);
//               },
//             ),
//             SizedBox(height: 20),
//             Text('Sensitivity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Slider(
//               value: sensitivity,
//               min: 0,
//               max: 1000,
//               divisions: 100,
//               label: sensitivity.round().toString(),
//               onChanged: (value) {
//                 setState(() {
//                   sensitivity = value;
//                 });
//               },
//               onChangeEnd: (value) {
//                 widget.onSensitivityChange(value);
//               },
//             ),
//             SizedBox(height: 20),
//             Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             if (_currentPosition != null)
//               Text('Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}')
//             else
//               Text('Location not available'),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationPage extends StatefulWidget {
  const GeolocationPage({super.key, Position? position});

  @override
  State<GeolocationPage> createState() => _GeolocationPageState();
}

class _GeolocationPageState extends State<GeolocationPage> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Location')),
      body: Center(
        child: _currentPosition != null
            ? Text('Latitude: ${_currentPosition!.latitude}\n'
                'Longitude: ${_currentPosition!.longitude}')
            : const CircularProgressIndicator(),
      ),
    );
  }
}