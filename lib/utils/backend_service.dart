import 'package:flutter/foundation.dart';
import '../models/seizure_prediction_data.dart';
import '../models/seizure_record.dart';
import '../services/seizure_prediction_service.dart';

/// 백엔드 서비스 클래스
class BackendService {
  /// 발작 예측 데이터 가져오기
  ///
  /// 1. 캐시된 예측 데이터가 있으면 반환
  /// 2. 없으면 백엔드에서 최신 예측 가져오기
  /// 3. 백엔드 실패 시 mock 데이터 반환
  static Future<SeizurePredictionData> fetchSeizurePrediction() async {
    // 1. 캐시된 데이터 확인
    final cachedPrediction = SeizurePredictionService.getLatestPrediction();
    if (cachedPrediction != null) {
      debugPrint('📦 캐시된 예측 데이터 사용');
      return cachedPrediction;
    }

    // 2. 백엔드에서 최신 예측 가져오기
    debugPrint('🌐 백엔드에서 최신 예측 데이터 가져오는 중...');
    try {
      final prediction = await SeizurePredictionService.fetchLatestPredictionFromBackend();
      if (prediction != null) {
        debugPrint('✅ 백엔드에서 예측 데이터 로드 성공');
        return prediction;
      }
    } catch (e) {
      debugPrint('⚠️ 백엔드 요청 실패: $e');
    }

    // 3. 백엔드 실패 시 mock 데이터 반환
    debugPrint('📝 Mock 데이터 사용 (백엔드 연결 실패)');
    return SeizurePredictionData.mock();
  }

  /// 발작 발생 확인 전송
  ///
  /// TODO: 실제 백엔드 연동 시:
  /// - Kotlin 백엔드 API 엔드포인트 연결
  /// - POST 요청으로 발작 발생 정보 전송
  static Future<void> confirmSeizureOccurred({
    required DateTime timestamp,
    required double predictionRate,
  }) async {
    // Mock: 백엔드 전송 시뮬레이션 (1초 지연)
    await Future.delayed(const Duration(milliseconds: 1000));

    // TODO: 실제 백엔드로 데이터 전송
    debugPrint('백엔드로 발작 발생 정보 전송:');
    debugPrint('  - 시간: $timestamp');
    debugPrint('  - 예측 확률: $predictionRate%');

    /* 실제 백엔드 연동 시 아래 코드 사용 예:

    final response = await http.post(
      Uri.parse('YOUR_BACKEND_API_URL/seizure-occurred'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'timestamp': timestamp.toIso8601String(),
        'predictionRate': predictionRate,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm seizure');
    }
    */
  }

  /// 발작 기록 가져오기
  ///
  /// TODO: 실제 백엔드 연동 시:
  /// - Kotlin 백엔드 API 엔드포인트 연결
  /// - GET 요청으로 발작 기록 리스트 가져오기
  static Future<List<SeizureRecord>> fetchSeizureRecords() async {
    // Mock: 백엔드 요청 시뮬레이션 (1.5초 지연)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock 데이터 반환
    return SeizureRecord.mockRecords();

    /* 실제 백엔드 연동 시 아래 코드 사용 예:

    final response = await http.get(
      Uri.parse('YOUR_BACKEND_API_URL/seizure-records'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SeizureRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load seizure records');
    }
    */
  }

  /// 특정 연도의 월별 발작 통계 가져오기
  ///
  /// TODO: 실제 백엔드 연동 시:
  /// - Kotlin 백엔드 API 엔드포인트 연결
  /// - 연도별 월별 통계 데이터 가져오기
  static Future<List<MonthlySeizureStats>> fetchMonthlyStats(int year) async {
    // Mock: 백엔드 요청 시뮬레이션 (1초 지연)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock 데이터 반환
    return MonthlySeizureStats.mockStats(year);

    /* 실제 백엔드 연동 시 아래 코드 사용 예:

    final response = await http.get(
      Uri.parse('YOUR_BACKEND_API_URL/seizure-stats/$year'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => MonthlySeizureStats.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load monthly stats');
    }
    */
  }

  /// 예측 응답 피드백 전송 (학습용)
  ///
  /// 사용자의 "예/아니요" 응답을 백엔드로 전송하여 개인별 패턴 학습에 활용
  ///
  /// TODO: 실제 백엔드 연동 시:
  /// - POST 요청으로 예측 피드백 정보 전송
  /// - 머신러닝 모델 재학습 트리거
  static Future<void> submitPredictionFeedback({
    required DateTime timestamp,
    required double predictionRate,
    required bool actualSeizureOccurred, // true: 발작 발생, false: 발작 미발생
    Map<String, dynamic>? additionalData, // 추가 생체 데이터
  }) async {
    // Mock: 백엔드 전송 시뮬레이션 (1초 지연)
    await Future.delayed(const Duration(milliseconds: 1000));

    // TODO: 실제 백엔드로 학습 데이터 전송
    debugPrint('=== 예측 피드백 전송 (학습용) ===');
    debugPrint('  - 시간: $timestamp');
    debugPrint('  - 예측 확률: $predictionRate%');
    debugPrint('  - 실제 발작 발생: ${actualSeizureOccurred ? "예" : "아니요"}');
    if (additionalData != null) {
      debugPrint('  - 추가 데이터: $additionalData');
    }
    debugPrint('  → 개인별 패턴 학습 데이터로 저장');
    debugPrint('================================');

    /* 실제 백엔드 연동 시 아래 코드 사용 예:

    final response = await http.post(
      Uri.parse('YOUR_BACKEND_API_URL/prediction-feedback'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'timestamp': timestamp.toIso8601String(),
        'predictionRate': predictionRate,
        'actualSeizureOccurred': actualSeizureOccurred,
        'additionalData': additionalData,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit prediction feedback');
    }
    */
  }

  /// 일반 데이터 가져오기 (다른 화면용)
  ///
  /// TODO: 필요한 다른 API 엔드포인트 추가
  static Future<T> fetchData<T>(
    Future<T> Function() fetchFunction, {
    Duration delay = const Duration(milliseconds: 1000),
  }) async {
    // Mock: 지연 시뮬레이션
    await Future.delayed(delay);
    return await fetchFunction();
  }
}
