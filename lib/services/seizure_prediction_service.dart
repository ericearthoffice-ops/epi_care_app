import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_sensor_data.dart';
import '../utils/notification_service.dart';

/// 발작 예측 서비스
/// 갤럭시 워치에서 받은 헬스 데이터를 백엔드로 전송하고
/// ML 모델의 발작 예측 결과를 받아 처리
class SeizurePredictionService {
  // TODO: 백엔드 서버 URL을 실제 주소로 변경
  static const String _baseUrl = 'https://your-backend-api.com';
  static const String _healthDataEndpoint = '/api/health-data';
  static const String _predictionEndpoint = '/api/seizure-prediction';

  // 발작 예측 threshold (예: 70%)
  static const double _seizurePredictionThreshold = 70.0;

  // 데이터 전송 주기 (초) - 너무 자주 보내면 서버 부하 발생
  static const int _sendIntervalSeconds = 10;

  Timer? _dataBufferTimer;
  final List<HealthSensorData> _dataBuffer = [];

  /// 헬스 데이터를 버퍼에 추가하고 주기적으로 백엔드에 전송
  void addHealthData(HealthSensorData data) {
    _dataBuffer.add(data);

    // 타이머가 없으면 생성
    _dataBufferTimer ??= Timer.periodic(
      const Duration(seconds: _sendIntervalSeconds),
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
      await sendHealthDataToBackend(dataToSend);
      debugPrint('Sent ${dataToSend.length} health data points to backend');
    } catch (e) {
      debugPrint('Failed to send health data: $e');
      // 실패한 데이터는 다시 버퍼에 추가 (재시도 로직)
      _dataBuffer.addAll(dataToSend);
    }
  }

  /// 즉시 버퍼에 누적된 데이터를 서버로 전송
  Future<void> flushBufferedData() async {
    await _sendBufferedData();
  }

  /// 헬스 데이터를 백엔드로 전송
  Future<Map<String, dynamic>> sendHealthDataToBackend(
    List<HealthSensorData> dataList,
  ) async {
    if (dataList.isEmpty) {
      return {'status': 'skipped'};
    }

    final timestamps = dataList.map((d) => d.timestamp).toList()..sort();
    final startTimestamp = timestamps.first.toIso8601String();
    final endTimestamp = timestamps.last.toIso8601String();
    final now = DateTime.now();
    final trackers = dataList.map((d) => d.type).toSet().toList();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_healthDataEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: 인증 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'metadata': {
            'batchSize': dataList.length,
            'trackers': trackers,
            'window': {'start': startTimestamp, 'end': endTimestamp},
            'sentAt': now.toIso8601String(),
          },
          'data': dataList.map((d) => d.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Backend response: $result');

        // 백엔드에서 발작 예측 결과가 바로 오는 경우
        if (result['predictionProbability'] != null) {
          _handlePredictionResult(result);
        }

        return result;
      } else {
        throw Exception(
          'Failed to send data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error sending health data: $e');
      rethrow;
    }
  }

  /// 발작 예측 결과 요청 (별도 API 호출 방식)
  Future<Map<String, dynamic>> requestSeizurePrediction() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_predictionEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: 인증 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        _handlePredictionResult(result);
        return result;
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error requesting seizure prediction: $e');
      rethrow;
    }
  }

  /// 발작 예측 결과 처리
  void _handlePredictionResult(Map<String, dynamic> result) {
    final predictionProbability = result['predictionProbability'] as double?;

    if (predictionProbability == null) return;

    debugPrint('발작 예측 확률: ${predictionProbability.toStringAsFixed(1)}%');

    // Threshold를 넘으면 알림 표시
    if (predictionProbability >= _seizurePredictionThreshold) {
      _showSeizureWarning(predictionProbability);
    } else {
      // Threshold 아래로 내려가면 알림 제거
      _clearSeizureWarning();
    }
  }

  /// 발작 경고 알림 제거 (threshold 아래로 내려갔을 때)
  Future<void> _clearSeizureWarning() async {
    debugPrint('✅ 발작 예측 확률이 threshold 아래로 내려감 - 알림 제거');
    await NotificationService.cancelSeizurePredictionNotification();
  }

  /// 발작 경고 알림 표시
  Future<void> _showSeizureWarning(double predictionRate) async {
    debugPrint('⚠️ 발작 경고 발생! 예측 확률: ${predictionRate.toStringAsFixed(1)}%');

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

    debugPrint('SeizurePredictionService disposed');
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[SeizurePredictionService] $message');
}
