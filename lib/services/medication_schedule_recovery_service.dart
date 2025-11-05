import 'package:flutter/material.dart';
import '../models/medication.dart';

/// 복약 스케줄 회복 결과
class RecoveryResult {
  final DateTime nextAlarmTime;
  final String message;
  final bool shouldSkipCurrentDose;
  final bool shouldAdjustNextDose;
  final double? adjustedDoseRatio; // 1.0 = 정상, 0.5 = 절반, 1.5 = 1.5배

  RecoveryResult({
    required this.nextAlarmTime,
    required this.message,
    this.shouldSkipCurrentDose = false,
    this.shouldAdjustNextDose = false,
    this.adjustedDoseRatio,
  });
}

/// 복약 주기 회복 알고리즘 서비스
/// PDF 문서 "소아 뇌전증 항발작제 복약 주기 회복 알고리즘 설계"를 기반으로 구현
class MedicationScheduleRecoveryService {
  /// 다음 알람 시간 계산
  ///
  /// [scheduledTime]: 원래 복용 예정 시간
  /// [actualTime]: 실제 복용한 시간
  /// [dosingInterval]: 투여 간격 (시간 단위)
  /// [medication]: 약물 정보
  RecoveryResult calculateNextAlarm({
    required DateTime scheduledTime,
    required DateTime actualTime,
    required double dosingInterval,
    required Medication medication,
  }) {
    // 1. 지연 시간 계산 (시간 단위)
    final delay = actualTime.difference(scheduledTime).inMinutes / 60.0;

    debugPrint('=== 복약 회복 알고리즘 ===');
    debugPrint('약물: ${medication.displayName}');
    debugPrint('예정 시간: $scheduledTime');
    debugPrint('실제 시간: $actualTime');
    debugPrint('지연 시간: ${delay.toStringAsFixed(2)}시간');
    debugPrint('투여 간격: $dosingInterval시간');

    // 2. 약물별 최소 안전 간격 설정
    final minSafeInterval = _getMinSafeInterval(dosingInterval, medication);
    debugPrint('최소 안전 간격: ${minSafeInterval.toStringAsFixed(2)}시간');

    // 3. 조기 복용 처리 (음수 지연)
    if (delay < 0) {
      final nextAlarm = scheduledTime.add(Duration(hours: dosingInterval.toInt()));
      return RecoveryResult(
        nextAlarmTime: nextAlarm,
        message: '예정보다 일찍 복용했습니다. 다음 복용은 평소 일정대로 유지합니다.',
      );
    }

    // 4. 완전 누락 처리 (지연 >= 투여 간격)
    if (delay >= dosingInterval) {
      final nextAlarm = scheduledTime.add(Duration(hours: dosingInterval.toInt()));

      // 약물별 처리
      if (_shouldSkipWithoutCompensation(medication)) {
        return RecoveryResult(
          nextAlarmTime: nextAlarm,
          message: '${medication.displayName} 복용을 많이 놓쳐 이미 예정 시간을 넘겼습니다.\n'
              '이번 용량은 건너뛰고 다음 용량부터 정상 일정으로 재개합니다.',
          shouldSkipCurrentDose: true,
        );
      }
    }

    // 5. 지연 복용 처리 (0 < delay < dosingInterval)
    final timeUntilNext = dosingInterval - delay; // 다음 복용까지 남은 시간
    debugPrint('다음 복용까지 남은 시간: ${timeUntilNext.toStringAsFixed(2)}시간');

    // Case 1: 남은 시간이 충분함 (>= 최소 안전 간격)
    if (timeUntilNext >= minSafeInterval) {
      final nextAlarm = scheduledTime.add(Duration(hours: dosingInterval.toInt()));

      if (delay == 0) {
        return RecoveryResult(
          nextAlarmTime: nextAlarm,
          message: '정시에 복용되었습니다. 다음 복용 알람은 평소 일정대로입니다.',
        );
      } else {
        return RecoveryResult(
          nextAlarmTime: nextAlarm,
          message: '약을 ${delay.toStringAsFixed(1)}시간 늦게 복용했습니다.\n'
              '하지만 다음 복용까지 충분한 시간이 있으므로 일정 그대로 진행합니다.',
        );
      }
    }

    // Case 2: 남은 시간이 부족함 (< 최소 안전 간격)
    // 필요한 추가 지연 시간
    final extraDelay = minSafeInterval - timeUntilNext;
    debugPrint('필요한 추가 지연: ${extraDelay.toStringAsFixed(2)}시간');

    // 추가 지연이 한 주기 이상이면 skip
    if (extraDelay >= dosingInterval) {
      final nextAlarm = scheduledTime.add(Duration(hours: dosingInterval.toInt()));
      return RecoveryResult(
        nextAlarmTime: nextAlarm,
        message: '다음 복용 시간이 너무 임박하여 이번 용량을 복용했습니다만,\n'
            '${medication.displayName} 특성상 안전을 위해 다음 예정 용량은 건너뜁니다.\n'
            '그 다음 일정으로 복귀합니다.',
        shouldSkipCurrentDose: true,
      );
    }

    // 다음 알람을 지연시켜 최소 간격 확보
    final delayMinutes = (dosingInterval * 60 + extraDelay * 60).toInt();
    final nextAlarm = scheduledTime.add(Duration(minutes: delayMinutes));

    String message = '이번 용량을 늦게 복용했으므로 다음 용량 알람을 '
        '${extraDelay.toStringAsFixed(1)}시간 늦췄습니다.\n'
        '이를 통해 두 번 복용 사이 간격을 확보합니다.';

    // 약물별 특수 지침 추가
    if (_requiresPartialDose(medication)) {
      message += '\n\n참고: ${medication.displayName}의 경우 지연 시 '
          '한 번에 모두 복용하지 않고 분할 복용하는 것이 권장됩니다.';
    }

    return RecoveryResult(
      nextAlarmTime: nextAlarm,
      message: message,
      shouldAdjustNextDose: _requiresPartialDose(medication),
      adjustedDoseRatio: _requiresPartialDose(medication) ? 0.5 : null,
    );
  }

  /// 약물별 최소 안전 간격 계산
  double _getMinSafeInterval(double dosingInterval, Medication medication) {
    final medName = medication.englishName.toLowerCase();

    // 페니토인: 매우 엄격 (조금이라도 지연되면 위험)
    if (medName.contains('phenytoin')) {
      return dosingInterval * 0.9; // 거의 전체 간격
    }

    // 클로바잠: 장시간 작용, 보수적 접근
    if (medName.contains('clobazam')) {
      return dosingInterval * 0.6;
    }

    // 톱리라메이트: 반감기 길어 비교적 여유
    if (medName.contains('topiramate')) {
      return dosingInterval * 0.5;
    }

    // 레비티라세탐: 단시간 작용
    if (medName.contains('levetiracetam') || medName.contains('keppra')) {
      if (dosingInterval >= 12) {
        // 1일 2회 이하
        return 6.0; // 최소 6시간
      } else {
        return dosingInterval * 0.5;
      }
    }

    // 발프로산: 중간 반감기
    if (medName.contains('valproate') || medName.contains('valproic')) {
      return dosingInterval * 0.5;
    }

    // 페노바르비탈, 조니사마이드: 초장시간 작용 (매우 관대)
    if (medName.contains('phenobarbital') || medName.contains('zonisamide')) {
      return dosingInterval * 0.3; // 30%만 확보해도 됨
    }

    // 기본값: 투여 간격의 50% (또는 짧은 간격은 75%)
    if (dosingInterval >= 8) {
      return dosingInterval * 0.5;
    } else {
      return dosingInterval * 0.75;
    }
  }

  /// 보상 없이 건너뛰어야 하는 약물인지 확인
  bool _shouldSkipWithoutCompensation(Medication medication) {
    final medName = medication.englishName.toLowerCase();

    // 소아의 경우 대부분 약물은 누락 시 보상 없이 skip
    // 특히 페니토인, 톱리라메이트는 절대 1.5배 복용 금지
    if (medName.contains('phenytoin') ||
        medName.contains('topiramate') ||
        medName.contains('clobazam')) {
      return true;
    }

    // 레비티라세탐도 소아는 skip 권장
    if (medName.contains('levetiracetam') || medName.contains('keppra')) {
      return true;
    }

    // 기본적으로 소아는 모두 skip (성인과 달리 1.5배 보충 안 함)
    return true;
  }

  /// 분할 복용이 필요한 약물인지 확인
  bool _requiresPartialDose(Medication medication) {
    final medName = medication.englishName.toLowerCase();

    // 클로바잠: 지연 시 분할 복용 권장
    if (medName.contains('clobazam')) {
      return true;
    }

    return false;
  }

  /// 1일 복용 횟수에 따른 권장 최소 간격 (시간)
  static double getRecommendedMinInterval(int dailyFrequency) {
    switch (dailyFrequency) {
      case 1: // 1일 1회 (24시간 간격)
        return 12.0; // 다음 복용 12시간 전
      case 2: // 1일 2회 (12시간 간격)
        return 6.0; // 다음 복용 6-8시간 전
      case 3: // 1일 3회 (8시간 간격)
        return 4.0; // 다음 복용 4시간 전
      default: // 더 자주 복용
        return 2.0; // 다음 복용 2-3시간 전
    }
  }
}
