import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override at build/run time:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  ///
  /// Android emulator → http://10.0.2.2:8000 (maps to host localhost)
  /// Physical device  → http://YOUR_PC_LAN_IP:8000  (e.g. http://192.168.1.5:8000)
  /// iOS simulator    → http://127.0.0.1:8000
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000';
      }
      return 'http://127.0.0.1:8000';
    }

    return 'https://employee-task-api.onrender.com';
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
