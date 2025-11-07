/// Samsung Galaxy Watch health sensor data model.
class HealthSensorData {
  HealthSensorData({
    required this.type,
    required this.timestamp,
    this.value,
    this.unit,
    this.status,
    this.heartRate,
    Map<String, dynamic>? metrics,
    Map<String, String>? units,
    Map<String, dynamic>? rawPayload,
    this.source,
    this.location,
  }) : metrics =
           metrics ?? (value != null ? {'value': value} : <String, dynamic>{}),
       units = units ?? (unit != null ? {'value': unit} : null),
       rawPayload = rawPayload ?? <String, dynamic>{};

  /// Tracker identifier. Examples: heart_rate, spo2, bia, ppg, ecg, ibi, eda.
  final String type;

  /// Primary scalar value for sensors that report a single measurement.
  final double? value;

  /// Unit of the primary scalar value.
  final String? unit;

  /// Raw tracker status code from Samsung Health Sensor SDK.
  final int? status;

  /// Timestamp produced by the watch.
  final DateTime timestamp;

  /// Optional heart-rate companion value (for composite readings like SpO₂).
  final double? heartRate;

  /// Arbitrary metrics reported together with this reading (multi-frequency BIA, etc.).
  final Map<String, dynamic> metrics;

  /// Units for each key inside [metrics].
  final Map<String, String>? units;

  /// Original payload delivered over the platform channel.
  final Map<String, dynamic> rawPayload;

  /// Source device identifier or tracker ID if exposed by the SDK.
  final String? source;

  /// Body location (wrist, finger, etc.) when provided.
  final String? location;

  /// Build an instance from the platform channel payload.
  factory HealthSensorData.fromMap(Map<dynamic, dynamic> map) {
    final mapped = map.map((key, value) => MapEntry(key.toString(), value));

    final dynamic metricsPayload = mapped['metrics'] ?? mapped['values'];
    Map<String, dynamic> metrics = {};
    if (metricsPayload is Map) {
      metrics = metricsPayload.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    double? value;
    if (mapped['value'] is num) {
      value = (mapped['value'] as num).toDouble();
    } else if (metrics['value'] is num) {
      value = (metrics['value'] as num).toDouble();
    }

    Map<String, String>? units;
    final dynamic unitsPayload = mapped['units'];
    if (unitsPayload is Map) {
      units = unitsPayload.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    final DateTime timestamp;
    if (mapped['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        mapped['timestamp'] as int,
      );
    } else if (mapped['timestamp'] is String) {
      timestamp =
          DateTime.tryParse(mapped['timestamp'] as String) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    final Map<String, dynamic> rawPayload = Map<String, dynamic>.from(mapped);

    return HealthSensorData(
      type: mapped['type']?.toString() ?? 'unknown',
      value: value,
      unit: mapped['unit']?.toString(),
      status: mapped['status'] is int ? mapped['status'] as int : null,
      timestamp: timestamp,
      heartRate: mapped['heartRate'] is num
          ? (mapped['heartRate'] as num).toDouble()
          : null,
      metrics: metrics,
      units: units,
      rawPayload: rawPayload,
      source: mapped['source']?.toString(),
      location: mapped['location']?.toString(),
    );
  }

  /// Serialize the reading for transmission to the backend.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      if (status != null) 'status': status,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (heartRate != null) 'heartRate': heartRate,
      if (metrics.isNotEmpty) 'metrics': metrics,
      if (units != null) 'units': units,
      if (source != null) 'source': source,
      if (location != null) 'location': location,
      if (rawPayload.isNotEmpty) 'raw': rawPayload,
    };
  }

  /// Human readable status string.
  String get statusDescription {
    switch (status) {
      case 0:
        return '정상';
      case 1:
        return '측정 중';
      case 2:
        return '주의 필요';
      case 3:
        return '측정 실패';
      case 4:
        return '센서 준비 중';
      default:
        return '상태 미확인';
    }
  }

  /// Typed helper for pulling double metrics.
  double? getMetricAsDouble(String key) {
    final dynamic metricValue = metrics[key];
    if (metricValue is num) {
      return metricValue.toDouble();
    }
    return null;
  }

  /// Determine if the primary heart-rate value falls inside a nominal range.
  bool get isHeartRateNormal {
    if (type != 'heart_rate' || value == null) return true;
    return value! >= 60 && value! <= 100;
  }

  /// Determine if the primary SpO₂ value falls inside a nominal range.
  bool get isSpo2Normal {
    if (type != 'spo2' || value == null) return true;
    return value! >= 95;
  }

  @override
  String toString() {
    return 'HealthSensorData{type: $type, value: $value, metrics: $metrics, timestamp: $timestamp}';
  }
}
