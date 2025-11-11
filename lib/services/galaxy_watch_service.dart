import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/health_sensor_data.dart';

/// Bridge between Flutter and the Samsung Health Sensor SDK running on the watch.
class GalaxyWatchService {
  GalaxyWatchService();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.epi_care_app/health_sensor',
  );

  static const EventChannel _eventChannel = EventChannel(
    'com.example.epi_care_app/health_sensor_stream',
  );

  /// Default tracker set used when the caller does not provide a custom list.
  static const List<String> _defaultTrackers = <String>[
    'heart_rate',
    'spo2',
    'bia',
    'mf_bia',
    'bio_active_sensor',
    'ecg',
    'eda',
    'ibi',
    'ppg',
    'sleep_stage',
    'skin_temperature',
  ];

  /// Expose the default tracker list for UI configuration.
  static List<String> get defaultTrackers =>
      List<String>.unmodifiable(_defaultTrackers);

  Stream<HealthSensorData>? _dataStream;

  /// Stream of structured readings arriving from the companion app.
  Stream<HealthSensorData> get healthDataStream {
    _dataStream ??= _eventChannel
        .receiveBroadcastStream()
        .asyncMap<HealthSensorData?>((dynamic event) async {
          try {
            if (event is Map) {
              return HealthSensorData.fromMap(
                Map<dynamic, dynamic>.from(event),
              );
            }
            if (event is Map<dynamic, dynamic>) {
              return HealthSensorData.fromMap(event);
            }
            debugPrint('Ignoring unexpected sensor payload: $event');
          } catch (error, stackTrace) {
            debugPrint('Failed to parse sensor payload: $error\n$stackTrace');
          }
          return null;
        })
        .where((event) => event != null)
        .cast<HealthSensorData>();

    return _dataStream!;
  }

  /// Initialise the Samsung Health Sensor tracker on the companion device.
  Future<Map<String, dynamic>> initialize({List<String>? trackers}) async {
    final Map<String, dynamic>? arguments =
        trackers != null && trackers.isNotEmpty ? {'trackers': trackers} : null;
    try {
      final result = await _methodChannel.invokeMethod('initialize', arguments);
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (error) {
      debugPrint('Failed to initialize: ${error.message}');
      rethrow;
    }
  }

  /// Start streaming health data for the requested trackers.
  Future<Map<String, dynamic>> startTracking({
    List<String>? trackers,
    Duration? samplingInterval,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'trackers': trackers != null && trackers.isNotEmpty
          ? trackers
          : _defaultTrackers,
      if (samplingInterval != null)
        'samplingIntervalMs': samplingInterval.inMilliseconds,
    };

    try {
      final result = await _methodChannel.invokeMethod(
        'startTracking',
        arguments,
      );
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (error) {
      debugPrint('Failed to start tracking: ${error.message}');
      rethrow;
    }
  }

  /// Stop streaming data for all trackers.
  Future<Map<String, dynamic>> stopTracking() async {
    try {
      final result = await _methodChannel.invokeMethod('stopTracking');
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (error) {
      debugPrint('Failed to stop tracking: ${error.message}');
      rethrow;
    }
  }

  /// Fetch the latest connection state from the companion app.
  Future<bool> isConnected() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException catch (error) {
      debugPrint('Failed to check connection: ${error.message}');
      return false;
    }
  }

  /// 필요한 모든 권한 확인
  /// Android 12+ 에서는 BLUETOOTH_CONNECT, BLUETOOTH_SCAN 필수
  Future<Map<Permission, PermissionStatus>> checkPermissions() async {
    final permissions = [
      Permission.bluetoothConnect, // Android 12+ 필수
      Permission.bluetoothScan, // Android 12+ 필수
      Permission.location, // 블루투스 스캔을 위해 필요
      Permission.sensors, // 센서 데이터 읽기
      Permission.notification, // Android 13+ 알림
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    debugPrint('Permission statuses: $statuses');
    return statuses;
  }

  /// 모든 필수 권한 요청
  Future<bool> requestPermissions() async {
    debugPrint('Requesting permissions...');

    final permissions = [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.sensors,
      Permission.notification,
    ];

    final statuses = await permissions.request();
    debugPrint('Permission request results: $statuses');

    // 필수 권한들이 모두 승인되었는지 확인
    final bluetoothConnect = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final bluetoothScan = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final location = statuses[Permission.location]?.isGranted ?? false;
    final sensors = statuses[Permission.sensors]?.isGranted ?? false;

    // Android 13+ 에서는 알림 권한도 필요하지만, 선택사항으로 처리
    final notification = statuses[Permission.notification]?.isGranted ?? true;

    final allGranted = bluetoothConnect && bluetoothScan && location && sensors;

    if (!allGranted) {
      debugPrint('Required permissions denied:');
      if (!bluetoothConnect) debugPrint('  - Bluetooth Connect');
      if (!bluetoothScan) debugPrint('  - Bluetooth Scan');
      if (!location) debugPrint('  - Location');
      if (!sensors) debugPrint('  - Sensors');
    }

    if (!notification) {
      debugPrint('Optional notification permission denied');
    }

    return allGranted;
  }

  /// 권한이 영구적으로 거부되었는지 확인
  Future<Map<Permission, bool>> checkPermanentlyDenied() async {
    final permissions = [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.sensors,
      Permission.notification,
    ];

    final permanentlyDenied = <Permission, bool>{};
    for (final permission in permissions) {
      permanentlyDenied[permission] = await permission.isPermanentlyDenied;
    }

    return permanentlyDenied;
  }

  /// Request a single-shot measurement for the given tracker type.
  Future<Map<String, dynamic>> measureOnce(String trackerType) async {
    try {
      final result = await _methodChannel.invokeMethod('measureOnce', {
        'tracker': trackerType,
      });
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (error) {
      debugPrint('Failed to measure $trackerType: ${error.message}');
      rethrow;
    }
  }

  /// Cancel streaming subscriptions and release native resources.
  void dispose() {}
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[GalaxyWatchService] $message');
}
