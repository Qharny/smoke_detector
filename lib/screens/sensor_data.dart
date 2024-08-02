import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification.dart';

class SensorData with ChangeNotifier {
  double _gasLevel = 0.0;
  bool _isConnected = false;
  late WebSocketChannel _channel;

  double get gasLevel => _gasLevel;
  bool get isConnected => _isConnected;

  void connectToSensor() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://your-esp32-ip-address:port'),
    );
    _isConnected = true;
    _channel.stream.listen(
      (data) {
        _gasLevel = double.parse(data);
        notifyListeners();
        if (_gasLevel > 500) {
          NotificationService().showNotification(
            'High Gas Level Detected!',
            'Current gas level: $_gasLevel ppm',
          );
        }
      },
      onDone: () {
        _isConnected = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error: $error');
        _isConnected = false;
        notifyListeners();
      },
    );
  }

  void disconnect() {
    _channel.sink.close();
    _isConnected = false;
    notifyListeners();
  }
}
