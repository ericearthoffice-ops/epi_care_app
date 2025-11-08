import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/health_sensor_data.dart';

/// 갤럭시 워치 건강 데이터 서비스
/// Health Connect를 통해 워치의 센서 데이터를 읽어옵니다
class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;

  /// Health Connect에서 읽을 데이터 타입
  final List<HealthDataType> _dataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  /// Health Connect 권한 요청
  Future<bool> requestAuthorization() async {
    try {
      debugPrint('🏥 Health Connect 권한 요청 중...');

      // 권한 요청 (읽기 권한만)
      _isAuthorized = await _health.requestAuthorization(_dataTypes);

      if (_isAuthorized) {
        debugPrint('✅ Health Connect 권한 승인됨');
      } else {
        debugPrint('❌ Health Connect 권한 거부됨');
      }

      return _isAuthorized;
    } catch (e) {
      debugPrint('❌ Health Connect 권한 요청 오류: $e');
      return false;
    }
  }

  /// 최근 심박수 데이터 가져오기 (최근 1시간)
  Future<List<HealthDataPoint>> getHeartRateData({
    Duration duration = const Duration(hours: 1),
  }) async {
    final now = DateTime.now();
    final startTime = now.subtract(duration);

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startTime,
        endTime: now,
      );

      debugPrint('💓 심박수 데이터 ${data.length}개 수신');
      return data;
    } catch (e) {
      debugPrint('❌ 심박수 데이터 가져오기 오류: $e');
      return [];
    }
  }

  /// 평균 심박수 계산
  Future<double?> getAverageHeartRate({
    Duration duration = const Duration(hours: 1),
  }) async {
    final data = await getHeartRateData(duration: duration);

    if (data.isEmpty) return null;

    double sum = 0;
    int count = 0;

    for (var point in data) {
      if (point.value is NumericHealthValue) {
        sum += (point.value as NumericHealthValue).numericValue;
        count++;
      }
    }

    return count > 0 ? sum / count : null;
  }

  /// 최근 걸음 수 가져오기 (오늘)
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      int totalSteps = 0;
      for (var point in data) {
        if (point.value is NumericHealthValue) {
          totalSteps += (point.value as NumericHealthValue).numericValue.toInt();
        }
      }

      debugPrint('👣 오늘 걸음 수: $totalSteps');
      return totalSteps;
    } catch (e) {
      debugPrint('❌ 걸음 수 가져오기 오류: $e');
      return 0;
    }
  }

  /// 어제 밤 수면 데이터 가져오기
  Future<Map<String, dynamic>> getLastNightSleep() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final startTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 0); // 어제 저녁 8시
    final endTime = DateTime(now.year, now.month, now.day, 12, 0); // 오늘 낮 12시

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_IN_BED,
        ],
        startTime: startTime,
        endTime: endTime,
      );

      if (data.isEmpty) {
        debugPrint('😴 수면 데이터 없음');
        return {
          'totalSleepMinutes': 0,
          'sleepQuality': 0.0,
        };
      }

      // 수면 시간 계산
      int totalSleepMinutes = 0;
      for (var point in data) {
        if (point.type == HealthDataType.SLEEP_ASLEEP) {
          if (point.value is NumericHealthValue) {
            totalSleepMinutes += (point.value as NumericHealthValue).numericValue.toInt();
          }
        }
      }

      debugPrint('😴 어제 밤 수면 시간: $totalSleepMinutes분');

      return {
        'totalSleepMinutes': totalSleepMinutes,
        'sleepQuality': totalSleepMinutes >= 360 ? 85.0 : (totalSleepMinutes / 360 * 85), // 6시간 이상이면 85%
      };
    } catch (e) {
      debugPrint('❌ 수면 데이터 가져오기 오류: $e');
      return {
        'totalSleepMinutes': 0,
        'sleepQuality': 0.0,
      };
    }
  }

  /// 최근 소모 칼로리 가져오기 (오늘)
  Future<double> getTodayActiveCalories() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startOfDay,
        endTime: now,
      );

      double totalCalories = 0;
      for (var point in data) {
        if (point.value is NumericHealthValue) {
          totalCalories += (point.value as NumericHealthValue).numericValue;
        }
      }

      debugPrint('🔥 오늘 소모 칼로리: $totalCalories kcal');
      return totalCalories;
    } catch (e) {
      debugPrint('❌ 칼로리 데이터 가져오기 오류: $e');
      return 0.0;
    }
  }

  /// 종합 건강 데이터 가져오기 (발작 예측용)
  Future<Map<String, dynamic>> getHealthDataForPrediction() async {
    try {
      debugPrint('📊 종합 건강 데이터 수집 중...');

      final heartRate = await getAverageHeartRate(duration: const Duration(minutes: 30));
      final steps = await getTodaySteps();
      final sleep = await getLastNightSleep();
      final calories = await getTodayActiveCalories();

      final data = {
        'heartRate': heartRate ?? 75.0, // 기본값 75 bpm
        'steps': steps,
        'sleepMinutes': sleep['totalSleepMinutes'],
        'sleepQuality': sleep['sleepQuality'],
        'activeCalories': calories,
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ 건강 데이터 수집 완료: $data');
      return data;
    } catch (e) {
      debugPrint('❌ 종합 건강 데이터 수집 오류: $e');
      // 오류 발생 시 기본값 반환
      return {
        'heartRate': 75.0,
        'steps': 0,
        'sleepMinutes': 0,
        'sleepQuality': 0.0,
        'activeCalories': 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Health Connect 사용 가능 여부 확인
  Future<bool> isHealthConnectAvailable() async {
    try {
      // Android 14 이상에서는 시스템에 내장
      // 그 이전 버전에서는 별도 앱 설치 필요
      final available = Health().isDataTypeAvailable(HealthDataType.HEART_RATE);
      debugPrint('🏥 Health Connect 사용 가능: $available');
      return available;
    } catch (e) {
      debugPrint('❌ Health Connect 확인 오류: $e');
      return false;
    }
  }

  /// Health Connect 데이터를 HealthSensorData 형식으로 변환
  /// (SeizurePredictionService에 전달하기 위함)
  List<HealthSensorData> convertToSensorData(Map<String, dynamic> healthData) {
    final List<HealthSensorData> sensorDataList = [];
    final timestamp = DateTime.tryParse(healthData['timestamp'] as String? ?? '') ?? DateTime.now();

    // 심박수 데이터
    if (healthData['heartRate'] != null) {
      sensorDataList.add(HealthSensorData(
        type: 'heart_rate',
        value: (healthData['heartRate'] as num).toDouble(),
        unit: 'bpm',
        timestamp: timestamp,
        source: 'Health Connect',
        location: 'wrist',
      ));
    }

    // 걸음 수 데이터
    if (healthData['steps'] != null) {
      sensorDataList.add(HealthSensorData(
        type: 'steps',
        value: (healthData['steps'] as num).toDouble(),
        unit: 'count',
        timestamp: timestamp,
        source: 'Health Connect',
      ));
    }

    // 수면 데이터
    if (healthData['sleepMinutes'] != null || healthData['sleepQuality'] != null) {
      sensorDataList.add(HealthSensorData(
        type: 'sleep',
        value: (healthData['sleepMinutes'] as num?)?.toDouble(),
        unit: 'minutes',
        timestamp: timestamp,
        source: 'Health Connect',
        metrics: {
          'duration': healthData['sleepMinutes'] ?? 0,
          'quality': healthData['sleepQuality'] ?? 0.0,
        },
        units: {
          'duration': 'minutes',
          'quality': 'percent',
        },
      ));
    }

    // 활동 칼로리 데이터
    if (healthData['activeCalories'] != null) {
      sensorDataList.add(HealthSensorData(
        type: 'calories',
        value: (healthData['activeCalories'] as num).toDouble(),
        unit: 'kcal',
        timestamp: timestamp,
        source: 'Health Connect',
      ));
    }

    return sensorDataList;
  }
}
