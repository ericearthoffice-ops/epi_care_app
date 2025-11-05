import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/medication_log.dart';
import '../models/medication_schedule.dart' as schedule;
import '../widgets/medication_time_input_screen.dart';
import '../main.dart' show navigatorKey;
import 'medication_schedule_recovery_service.dart';
import 'dart:convert';

/// 복용 알림 서비스
class MedicationNotificationService {
  static final MedicationNotificationService _instance = MedicationNotificationService._internal();
  factory MedicationNotificationService() => _instance;
  MedicationNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // 복용 기록 저장소 (실제로는 백엔드에 저장)
  final Map<int, MedicationLog> _medicationLogs = {};

  // 재시도 타이머 저장소
  final Map<int, int> _retryAttempts = {};

  // 스케줄 정보 저장 (복약 회복 알고리즘용)
  final Map<int, schedule.MedicationSchedule> _scheduleInfo = {};

  // 복약 회복 알고리즘 서비스
  final _recoveryService = MedicationScheduleRecoveryService();

  /// 초기화
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'medication_reminder',
      '복용 알림',
      description: '약 복용 시간 알림',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// 알림 응답 처리 (액션 버튼 클릭)
  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final data = jsonDecode(payload);
    final notificationId = data['notificationId'] as int;
    final action = response.actionId;

    if (action == 'take') {
      // 복용 완료
      _markAsTaken(notificationId);
    } else if (action == 'skip') {
      // 복용 안함
      _markAsSkipped(notificationId);
    } else if (action == 'input') {
      // 복용 시간 입력 화면으로 이동
      _openInputScreen(notificationId);
    }
  }

  /// 복용 스케줄에 따라 알림 예약
  Future<void> scheduleMedicationAlarms(List<schedule.MedicationSchedule> schedules) async {
    // 기존 알림 모두 취소
    await _notifications.cancelAll();
    _scheduleInfo.clear();
    _medicationLogs.clear();
    _retryAttempts.clear();

    int notificationId = 0;
    for (final medicationSchedule in schedules) {
      for (final time in medicationSchedule.times) {
        // 각 복용 시간마다 알림 설정
        await _scheduleSingleAlarm(
          notificationId,
          medicationSchedule.medication.displayName,
          time,
        );

        // 복용 기록 초기화
        _medicationLogs[notificationId] = MedicationLog(
          medicationName: medicationSchedule.medication.displayName,
          scheduledTime: _getNextScheduledTime(time),
        );

        // 스케줄 정보 저장 (복약 회복 알고리즘용)
        _scheduleInfo[notificationId] = medicationSchedule;

        notificationId++;
      }
    }

    debugPrint('복용 알림 $notificationId개 예약 완료');
  }

  /// 단일 알림 예약
  Future<void> _scheduleSingleAlarm(
    int notificationId,
    String medicationName,
    schedule.TimeOfDay time,
  ) async {
    final scheduledTime = _getNextScheduledTime(time);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      '복용 알림',
      channelDescription: '약 복용 시간 알림',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take',
          '✓',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'skip',
          '✗',
          showsUserInterface: false,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      notificationId,
      'Seizure시계',
      '$medicationName 복용 시간입니다',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'notificationId': notificationId,
        'medicationName': medicationName,
      }),
    );
  }

  /// 다음 예정 시간 계산
  tz.TZDateTime _getNextScheduledTime(schedule.TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 이미 지난 시간이면 다음날로
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  /// 복용 완료 처리 (스마트 알람 재조정)
  Future<void> _markAsTaken(int notificationId) async {
    final log = _medicationLogs[notificationId];
    final scheduleInfo = _scheduleInfo[notificationId];
    if (log == null || scheduleInfo == null) return;

    final actualTime = DateTime.now();
    log.status = MedicationStatus.taken;
    log.actualTime = actualTime;

    // 알림 취소
    await _notifications.cancel(notificationId);
    _retryAttempts.remove(notificationId);

    debugPrint('복용 완료: ${log.medicationName} at $actualTime');

    // 복약 회복 알고리즘 적용
    final dosingInterval = 24.0 / scheduleInfo.dailyFrequency; // 시간 단위
    final recoveryResult = _recoveryService.calculateNextAlarm(
      scheduledTime: log.scheduledTime,
      actualTime: actualTime,
      dosingInterval: dosingInterval,
      medication: scheduleInfo.medication,
    );

    debugPrint('회복 알고리즘 결과: ${recoveryResult.message}');
    debugPrint('다음 알람: ${recoveryResult.nextAlarmTime}');

    // 다음 알람 재예약
    if (!recoveryResult.shouldSkipCurrentDose) {
      await _rescheduleNextAlarm(
        notificationId,
        scheduleInfo.medication.displayName,
        recoveryResult.nextAlarmTime,
      );

      // 다음 복용 로그 생성
      _medicationLogs[notificationId] = MedicationLog(
        medicationName: scheduleInfo.medication.displayName,
        scheduledTime: recoveryResult.nextAlarmTime,
      );
    }

    // 백엔드로 전송
    _sendToBackend(log);
  }

  /// 복용 안함 처리
  Future<void> _markAsSkipped(int notificationId) async {
    final log = _medicationLogs[notificationId];
    if (log == null) return;

    log.status = MedicationStatus.skipped;
    log.actualTime = DateTime.now();

    // 알림 취소
    await _notifications.cancel(notificationId);
    _retryAttempts.remove(notificationId);

    debugPrint('복용 안함: ${log.medicationName}');

    // 복용 안함은 다음 정규 알람으로 자동 진행
    // (별도 조정 없이 기존 스케줄 유지)

    // 백엔드로 전송
    _sendToBackend(log);
  }

  /// 다음 알람 재예약
  Future<void> _rescheduleNextAlarm(
    int notificationId,
    String medicationName,
    DateTime nextAlarmTime,
  ) async {
    final scheduledTime = tz.TZDateTime.from(nextAlarmTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      '복용 알림',
      channelDescription: '약 복용 시간 알림',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('take', '✓', showsUserInterface: false),
        AndroidNotificationAction('skip', '✗', showsUserInterface: false),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      notificationId,
      'Seizure시계',
      '$medicationName 복용 시간입니다',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'notificationId': notificationId,
        'medicationName': medicationName,
      }),
    );

    debugPrint('다음 알람 재예약: $medicationName at $nextAlarmTime');
  }

  /// 무응답 시 재시도 (5분 간격, 최대 3회)
  Future<void> retryNotification(int notificationId) async {
    final log = _medicationLogs[notificationId];
    if (log == null) return;

    // 재시도 횟수 증가
    _retryAttempts[notificationId] = (_retryAttempts[notificationId] ?? 0) + 1;
    log.notificationAttempts = _retryAttempts[notificationId]!;

    if (_retryAttempts[notificationId]! >= 3) {
      // 3회 실패 -> 놓침으로 기록하고 1시간마다 입력 알림
      log.status = MedicationStatus.missed;
      _sendToBackend(log);
      await _scheduleHourlyInputReminder(notificationId, log.medicationName);
      debugPrint('${log.medicationName} 3회 무응답 -> 시간 입력 알림으로 전환');
    } else {
      // 5분 후 재시도
      await Future.delayed(const Duration(minutes: 5));

      const androidDetails = AndroidNotificationDetails(
        'medication_reminder',
        '복용 알림',
        channelDescription: '약 복용 시간 알림',
        importance: Importance.high,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('take', '✓', showsUserInterface: false),
          AndroidNotificationAction('skip', '✗', showsUserInterface: false),
        ],
      );

      await _notifications.show(
        notificationId,
        'Seizure시계',
        '${log.medicationName} 복용 시간입니다 (${_retryAttempts[notificationId]}/3)',
        const NotificationDetails(android: androidDetails),
        payload: jsonEncode({
          'notificationId': notificationId,
          'medicationName': log.medicationName,
        }),
      );

      debugPrint('${log.medicationName} 재시도 ${_retryAttempts[notificationId]}/3');
    }
  }

  /// 1시간마다 시간 입력 알림
  Future<void> _scheduleHourlyInputReminder(int notificationId, String medicationName) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      '복용 알림',
      channelDescription: '약 복용 시간 입력 요청',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'input',
          '시간 입력하기',
          showsUserInterface: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // 1시간마다 반복
    await _notifications.periodicallyShow(
      notificationId + 10000, // ID 충돌 방지
      'Seizure시계',
      '$medicationName 마지막 복용 시간을 입력해주세요',
      RepeatInterval.hourly,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode({
        'notificationId': notificationId,
        'medicationName': medicationName,
        'type': 'input_reminder',
      }),
    );
  }

  /// 복용 시간 입력 화면 열기
  void _openInputScreen(int notificationId) {
    final log = _medicationLogs[notificationId];
    if (log == null) return;

    // GlobalKey를 통해 입력 화면으로 이동
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MedicationTimeInputScreen(
          notificationId: notificationId,
          medicationName: log.medicationName,
        ),
      ),
    );

    debugPrint('복용 시간 입력 화면 열기: ${log.medicationName}');
  }

  /// 백엔드로 데이터 전송
  Future<void> _sendToBackend(MedicationLog log) async {
    // TODO: 실제 백엔드 API 호출
    debugPrint('=== 백엔드 전송 ===');
    debugPrint(jsonEncode(log.toJson()));
    debugPrint('ML 학습 데이터: ${log.status.name}, 시간차: ${log.actualTime?.difference(log.scheduledTime).inMinutes ?? 'N/A'}분');
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    await _notifications.cancel(notificationId + 10000); // 입력 알림도 취소
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _medicationLogs.clear();
    _retryAttempts.clear();
  }
}
