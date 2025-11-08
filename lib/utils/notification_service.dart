import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 발작 예측 알림 서비스
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 알림 채널 ID
  static const String _channelId = 'seizure_prediction_channel';
  static const String _channelName = '발작 예측 알림';
  static const String _channelDescription = '발작 예상 확률이 높을 때 알림';

  /// 알림 ID (고정 - ongoing notification을 위해)
  static const int _notificationId = 1;

  /// 초기화
  static Future<void> initialize({
    required Function(String?) onNotificationTapped,
  }) async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정 (필요시)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 초기화 및 알림 클릭 핸들러 설정
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 시 호출 (foreground + background 앱이 실행 중일 때)
        debugPrint('onDidReceiveNotificationResponse: ${response.payload}');
        onNotificationTapped(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
    );

    // Android 권한 요청
    await _requestPermissions();

    debugPrint('NotificationService 초기화 완료');
  }

  /// Background 알림 핸들러 (Top-level function이어야 함)
  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse response) {
    // Background에서 알림 클릭 시 호출
    debugPrint('Background notification tapped: ${response.payload}');
    // 이 핸들러는 isolate에서 실행되므로 직접 navigation을 할 수 없음
    // 대신 MainNavigation의 initState에서 getNotificationAppLaunchDetails로 체크
  }

  /// 권한 요청 (Android 13+)
  static Future<void> _requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// 발작 예측 알림 표시
  ///
  /// [predictionRate] - 예측 확률 (0-100)
  /// [isOngoing] - true로 설정하면 사용자가 직접 닫을 수 없는 ongoing notification
  ///
  /// Threshold(70%) 이상일 때만 알림 표시
  /// SeizurePredictionService에서 threshold 아래로 내려가면 자동으로 알림 제거
  static Future<void> showSeizurePredictionNotification({
    required double predictionRate,
    bool isOngoing = true, // ongoing으로 설정하면 알림창에 계속 떠있음
  }) async {
    debugPrint('발작 예측 알림 표시: ${predictionRate.toInt()}%');

    // Android 알림 상세 설정
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: isOngoing, // true로 설정하면 사용자가 스와이프로 닫을 수 없음
      autoCancel: !isOngoing, // ongoing이면 자동으로 닫히지 않음
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      // 알림 스타일
      styleInformation: BigTextStyleInformation(
        '앱으로 들어와 확인해주세요.',
        contentTitle: '발작이 예상되고 있습니다.',
        summaryText: '발작 예측 확률: ${predictionRate.toInt()}%',
      ),
    );

    // iOS 알림 상세 설정
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 알림 표시
    await _notifications.show(
      _notificationId,
      'Seizure시계',
      '발작이 예상되고 있습니다.',
      details,
      payload: 'seizure_prediction', // 알림 클릭 시 전달될 데이터
    );
  }

  /// 발작 예측 알림 제거
  ///
  /// TODO: 실제 운영 시에는 예측 확률이 threshold 아래로 내려갈 때 호출
  static Future<void> cancelSeizurePredictionNotification() async {
    await _notifications.cancel(_notificationId);
    debugPrint('발작 예측 알림 제거');
  }

  /// 모든 알림 제거
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('모든 알림 제거');
  }
}
