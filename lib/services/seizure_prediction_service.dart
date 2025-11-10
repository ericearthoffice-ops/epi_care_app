import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/health_sensor_data.dart';
import '../models/seizure_prediction_data.dart';
import '../utils/notification_service.dart';

/// 발작 예측 서비스
/// 갤럭시 워치에서 받은 헬스 데이터를 백엔드로 전송하고
/// ML 모델의 발작 예측 결과를 받아 처리
class SeizurePredictionService {
  // 백엔드 서버 URL (config.dart에서 가져옴)
  static final String _baseUrl = AppConfig.baseUrl;
  static final String _bioRecordEndpoint = AppConfig.bioRecordEndpoint;
  static final String _getLatestPredictionEndpoint = AppConfig.getLatestPredictionEndpoint;

  // 발작 예측 threshold
  static final double _seizurePredictionThreshold = AppConfig.predictionThreshold;

  // 데이터 전송 주기 (초)
  static final int _sendIntervalSeconds = AppConfig.dataTransmissionInterval;

  // 최신 예측 결과 캐싱 (알림 탭 시 사용)
  static SeizurePredictionData? _latestPredictionData;

  Timer? _dataBufferTimer;
  final List<HealthSensorData> _dataBuffer = [];

  // 변화율 계산을 위한 이전 값 저장
  final Map<String, double> _previousValues = {};

  // 수면/식이/복약 데이터 (앱의 다른 부분에서 설정 가능)
  double _sleepTimeHours = 7.0;
  double _ketoAdherence = 80.0;
  double _medicationAdherence = 90.0;

  /// 헬스 데이터를 버퍼에 추가하고 주기적으로 백엔드에 전송
  void addHealthData(HealthSensorData data) {
    _dataBuffer.add(data);

    // 타이머가 없으면 생성
    _dataBufferTimer ??= Timer.periodic(
      Duration(seconds: _sendIntervalSeconds),
      (_) => _sendBufferedData(),
    );
  }

  /// 버퍼에 쌓인 데이터를 백엔드에 전송
  Future<void> _sendBufferedData() async {
    if (_dataBuffer.isEmpty) return;

    // 버퍼 복사 후 초기화
    final dataToSend = List<HealthSensorData>.from(_dataBuffer);
    _dataBuffer.clear();

    try {
      await sendBioRecordToBackend(dataToSend);
      _log('Sent ${dataToSend.length} health data points to backend');
    } catch (e) {
      _log('Failed to send health data: $e');
      // 실패한 데이터는 다시 버퍼에 추가 (재시도 로직)
      _dataBuffer.addAll(dataToSend);
    }
  }

  /// 센서 데이터를 집계하여 최신 값 추출
  Map<String, double> _aggregateSensorData(List<HealthSensorData> dataList) {
    final Map<String, double> latestValues = {};

    for (var data in dataList) {
      if (data.value != null) {
        latestValues[data.type] = data.value!;
      }
    }

    return latestValues;
  }

  /// 변화율 계산 (이전 값 대비)
  double _calculateChange(String sensorType, double currentValue) {
    if (!_previousValues.containsKey(sensorType)) {
      _previousValues[sensorType] = currentValue;
      return 0.0;
    }

    final previousValue = _previousValues[sensorType]!;
    final change = currentValue - previousValue;
    _previousValues[sensorType] = currentValue;

    return change;
  }

  /// 즉시 버퍼에 누적된 데이터를 서버로 전송
  Future<void> flushBufferedData() async {
    await _sendBufferedData();
  }

  /// BioRecord 형식으로 헬스 데이터를 백엔드에 전송
  Future<Map<String, dynamic>> sendBioRecordToBackend(
    List<HealthSensorData> dataList,
  ) async {
    if (dataList.isEmpty) {
      return {'status': 'skipped'};
    }

    // 센서 데이터 집계
    final sensorValues = _aggregateSensorData(dataList);

    // 각 센서별 변화율 계산
    final emgValue = sensorValues['eda'] ?? 0.5; // EDA를 EMG로 매핑
    final emgChange = _calculateChange('emg', emgValue);

    final ecgValue = sensorValues['heart_rate'] ?? sensorValues['ecg'] ?? 75.0;
    final ecgChange = _calculateChange('ecg', ecgValue);

    // IBI 변동성을 가속도계 대용으로 사용
    final accelerometerValue = (sensorValues['ibi'] ?? 800.0) / 400.0; // IBI를 0-2 범위로 정규화
    final accelerometerChange = _calculateChange('accelerometer', accelerometerValue);

    final sleepChange = _calculateChange('sleep', _sleepTimeHours);
    final ketoChange = _calculateChange('keto', _ketoAdherence);
    final medicationChange = _calculateChange('medication', _medicationAdherence);

    // 스트레스 지수 계산 (PPG, EDA, 심박수 기반)
    final stressValue = _calculateStressIndex(sensorValues);
    final stressChange = _calculateChange('stress', stressValue);

    // BioRecord 생성
    final bioRecord = {
      'userId': AppConfig.defaultUserId,
      'timestamp': DateTime.now().toIso8601String(),
      'predictionRate': 0, // 서버에서 계산
      'actualSeizureOccurred': false,
      'userNotes': null,
      'emgData': {
        'value': emgValue,
        'change': emgChange,
      },
      'ecgData': {
        'value': ecgValue,
        'change': ecgChange,
      },
      'accelerometerData': {
        'value': accelerometerValue,
        'change': accelerometerChange,
      },
      'sleepTimeData': {
        'value': _sleepTimeHours,
        'change': sleepChange,
      },
      'ketoAdherenceData': {
        'value': _ketoAdherence,
        'change': ketoChange,
      },
      'medicationAdherenceData': {
        'value': _medicationAdherence,
        'change': medicationChange,
      },
      'stressIndexData': {
        'value': stressValue,
        'change': stressChange,
      },
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_bioRecordEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: 인증 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bioRecord),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        _log('Backend response: $result');

        // 백엔드에서 발작 예측 결과 처리
        if (result['prediction_rate'] != null || result['predictionRate'] != null) {
          _handlePredictionResult(result);
        }

        return result;
      } else {
        throw Exception(
          'Failed to send data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _log('Error sending BioRecord: $e');
      rethrow;
    }
  }

  /// 스트레스 지수 계산 (센서 데이터 기반)
  double _calculateStressIndex(Map<String, double> sensorValues) {
    // 심박수 기반 스트레스 (60-100 정상, 100+ 스트레스)
    final heartRate = sensorValues['heart_rate'] ?? 75.0;
    final heartRateStress = ((heartRate - 60) / 40 * 50).clamp(0.0, 100.0);

    // EDA 기반 스트레스 (피부전기활동 높을수록 스트레스)
    final eda = sensorValues['eda'] ?? 0.5;
    final edaStress = (eda * 50).clamp(0.0, 100.0);

    // IBI 변동성 기반 (낮을수록 스트레스)
    final ibi = sensorValues['ibi'] ?? 800.0;
    final ibiStress = ((1000 - ibi) / 10).clamp(0.0, 100.0);

    // 종합 스트레스 지수 (가중 평균)
    final totalStress = (heartRateStress * 0.4 + edaStress * 0.4 + ibiStress * 0.2).clamp(0.0, 100.0);

    return totalStress.toDouble();
  }

  /// 수면 시간 설정 (앱의 다른 부분에서 호출)
  void setSleepTime(double hours) {
    _sleepTimeHours = hours;
  }

  /// 케톤 식이 순응도 설정
  void setKetoAdherence(double percentage) {
    _ketoAdherence = percentage;
  }

  /// 복약 준수율 설정
  void setMedicationAdherence(double percentage) {
    _medicationAdherence = percentage;
  }


  /// 발작 예측 결과 처리
  void _handlePredictionResult(Map<String, dynamic> result) {
    try {
      // prediction_rate (백엔드 응답)를 predictionRate로 변환
      if (result.containsKey('prediction_rate') && !result.containsKey('predictionRate')) {
        result['predictionRate'] = result['prediction_rate'];
      }

      // 백엔드 응답을 SeizurePredictionData로 변환
      final predictionData = SeizurePredictionData.fromJson(result);

      // 최신 예측 결과 캐싱
      _latestPredictionData = predictionData;

      final predictionProbability = predictionData.predictionRate;

      _log('발작 예측 확률: ${predictionProbability.toStringAsFixed(1)}%');

      // Threshold를 넘으면 알림 표시
      if (predictionProbability >= _seizurePredictionThreshold) {
        _showSeizureWarning(predictionProbability);
      } else {
        // Threshold 아래로 내려가면 알림 제거
        _clearSeizureWarning();
      }
    } catch (e) {
      _log('예측 결과 파싱 오류: $e');
      // 파싱 실패 시 숫자 필드로 직접 접근
      final predictionProbability = (result['predictionRate'] ?? result['prediction_rate'] ?? result['predictionProbability']) as num?;
      if (predictionProbability != null && predictionProbability.toDouble() >= _seizurePredictionThreshold) {
        _showSeizureWarning(predictionProbability.toDouble());
      }
    }
  }

  /// 최신 예측 결과 가져오기 (캐시된 데이터)
  static SeizurePredictionData? getLatestPrediction() {
    return _latestPredictionData;
  }

  /// 백엔드에서 최신 예측 결과 가져오기 (GET 요청)
  static Future<SeizurePredictionData?> fetchLatestPredictionFromBackend({
    String userId = 'default_user',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_getLatestPredictionEndpoint?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: 인증 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        final predictionData = SeizurePredictionData.fromJson(result);
        _latestPredictionData = predictionData;
        return predictionData;
      } else {
        _log('Failed to fetch latest prediction: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error fetching latest prediction: $e');
      return null;
    }
  }

  /// 발작 경고 알림 제거 (threshold 아래로 내려갔을 때)
  Future<void> _clearSeizureWarning() async {
    _log('✅ 발작 예측 확률이 threshold 아래로 내려감 - 알림 제거');
    await NotificationService.cancelSeizurePredictionNotification();
  }

  /// 발작 경고 알림 표시
  Future<void> _showSeizureWarning(double predictionRate) async {
    _log('⚠️ 발작 경고 발생! 예측 확률: ${predictionRate.toStringAsFixed(1)}%');

    // 이전에 구현한 발작 예측 알림 사용
    await NotificationService.showSeizurePredictionNotification(
      predictionRate: predictionRate,
      isOngoing: true, // 알림창에 계속 표시
    );
  }

  /// 서비스 정리
  void dispose() {
    _dataBufferTimer?.cancel();
    _dataBufferTimer = null;
    _dataBuffer.clear();

    _log('SeizurePredictionService disposed');
  }
}

void _log(String message) {
  // ignore: avoid_print
  print('[SeizurePredictionService] $message');
}
