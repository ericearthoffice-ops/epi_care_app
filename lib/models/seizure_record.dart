/// 발작 기록 모델
class SeizureRecord {
  final String id;
  final DateTime date; // 발작 날짜 및 시간
  final Duration duration; // 지속 시간
  final String? note; // 메모 (선택 사항)

  SeizureRecord({
    required this.id,
    required this.date,
    required this.duration,
    this.note,
  });

  /// 시간 표시 (예: "오후 2시 34분")
  String get timeDisplay {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$period $displayHour시 $minute분';
  }

  /// 지속 시간 표시 (예: "3m", "1~2m")
  String get durationDisplay {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = duration.inHours;
      return '${hours}h';
    }
  }

  /// Mock 데이터 생성
  static List<SeizureRecord> mockRecords() {
    return [
      SeizureRecord(
        id: '1',
        date: DateTime(2025, 7, 12, 14, 34),
        duration: const Duration(minutes: 3),
        note: '오후 산책 중 발작',
      ),
      SeizureRecord(
        id: '2',
        date: DateTime(2025, 12, 23, 9, 15),
        duration: const Duration(minutes: 1, seconds: 30),
        note: '아침 식사 전',
      ),
      SeizureRecord(
        id: '3',
        date: DateTime(2025, 7, 10, 20, 45),
        duration: const Duration(minutes: 2),
      ),
      SeizureRecord(
        id: '4',
        date: DateTime(2025, 12, 20, 15, 20),
        duration: const Duration(minutes: 4),
        note: '스트레스 상황',
      ),
      SeizureRecord(
        id: '5',
        date: DateTime(2025, 6, 5, 11, 30),
        duration: const Duration(minutes: 2, seconds: 30),
      ),
      SeizureRecord(
        id: '6',
        date: DateTime(2025, 3, 18, 8, 10),
        duration: const Duration(minutes: 1),
      ),
      SeizureRecord(
        id: '7',
        date: DateTime(2025, 3, 25, 16, 40),
        duration: const Duration(minutes: 5),
        note: '긴 발작',
      ),
    ];
  }
}

/// 월별 발작 통계
class MonthlySeizureStats {
  final int year;
  final int month;
  final int count; // 발작 횟수

  MonthlySeizureStats({
    required this.year,
    required this.month,
    required this.count,
  });

  /// 파란색 농도 계산 (0.0 ~ 1.0)
  /// 0회: 0.1, 1-2회: 0.3, 3-4회: 0.6, 5회 이상: 1.0
  double get intensity {
    if (count == 0) return 0.1;
    if (count <= 2) return 0.3;
    if (count <= 4) return 0.6;
    return 1.0;
  }

  /// Mock 데이터 생성
  static List<MonthlySeizureStats> mockStats(int year) {
    return [
      MonthlySeizureStats(year: year, month: 1, count: 0),
      MonthlySeizureStats(year: year, month: 2, count: 1),
      MonthlySeizureStats(year: year, month: 3, count: 2),
      MonthlySeizureStats(year: year, month: 4, count: 0),
      MonthlySeizureStats(year: year, month: 5, count: 0),
      MonthlySeizureStats(year: year, month: 6, count: 1),
      MonthlySeizureStats(year: year, month: 7, count: 2),
      MonthlySeizureStats(year: year, month: 8, count: 0),
      MonthlySeizureStats(year: year, month: 9, count: 0),
      MonthlySeizureStats(year: year, month: 10, count: 0),
      MonthlySeizureStats(year: year, month: 11, count: 0),
      MonthlySeizureStats(year: year, month: 12, count: 2),
    ];
  }
}

/// 정렬 기준
enum SortOrder {
  newest('최신순'),
  oldest('오래된순'),
  duration('지속시간순');

  final String label;
  const SortOrder(this.label);
}
