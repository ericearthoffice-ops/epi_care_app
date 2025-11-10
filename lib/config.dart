/// 앱 전역 설정
class AppConfig {
  /// 백엔드 API 서버 URL
  /// Google Cloud Run에 배포된 Ktor 서버
  static const String baseUrl = 'https://ktor-server-292436853079.asia-northeast3.run.app';

  /// API 엔드포인트
  /// BioRecord 전송 및 발작 예측 (POST)
  static const String bioRecordEndpoint = '/seizure-prediction';

  /// 최신 발작 예측 조회 (GET)
  static const String getLatestPredictionEndpoint = '/api/seizure-prediction';

  /// 커뮤니티 게시글 (POST: 작성, GET: 조회)
  static const String communityPostsEndpoint = '/community/posts';

  /// 사용자 ID (추후 인증 시스템으로 대체)
  static const int defaultUserId = 1;

  /// 예측 임계값 (70% 이상 시 경고)
  static const double predictionThreshold = 70.0;

  /// 데이터 전송 주기 (초)
  static const int dataTransmissionInterval = 10;

  /// 요청 타임아웃 (초)
  static const int requestTimeout = 30;
}
