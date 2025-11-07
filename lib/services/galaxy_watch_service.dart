import 'dart:async';

import 'package:flutter/services.dart';

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
