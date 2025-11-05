import 'medication.dart';

/// 복용 스케줄 모델
class MedicationSchedule {
  final Medication medication;
  int dailyFrequency; // 하루 복용 횟수
  List<TimeOfDay> times; // 복용 시간들
  String dosage; // 복용 용량 (예: "1정", "5ml")
  String? notes; // 추가 메모 (선택사항)

  MedicationSchedule({
    required this.medication,
    this.dailyFrequency = 1,
    List<TimeOfDay>? times,
    this.dosage = '',
    this.notes,
  }) : times = times ?? [const TimeOfDay(hour: 9, minute: 0)];

  /// 복용 시간 리스트 업데이트 (주기 변경 시)
  void updateTimesForFrequency() {
    if (times.length > dailyFrequency) {
      times = times.sublist(0, dailyFrequency);
    } else if (times.length < dailyFrequency) {
      while (times.length < dailyFrequency) {
        // 마지막 시간에서 4시간 후로 추가
        final lastTime = times.last;
        final newHour = (lastTime.hour + 4) % 24;
        times.add(TimeOfDay(hour: newHour, minute: lastTime.minute));
      }
    }
  }
}

/// 시간 표시용 확장
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String formatAmPm() {
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format24Hour();
}
