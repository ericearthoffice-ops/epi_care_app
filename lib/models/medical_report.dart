/// 의료 보고서 모델
/// 의료진에게 제출할 환자의 건강 기록 요약
class MedicalReport {
  final DateTime startDate;
  final DateTime endDate;
  final SeizureStatistics seizureStats;
  final MedicationAdherence medicationAdherence;
  final DietSummary dietSummary;

  MedicalReport({
    required this.startDate,
    required this.endDate,
    required this.seizureStats,
    required this.medicationAdherence,
    required this.dietSummary,
  });

  /// 보고서 기간 (일 단위)
  int get periodDays => endDate.difference(startDate).inDays + 1;
}

/// 발작 통계
class SeizureStatistics {
  final int totalSeizures; // 총 발작 횟수
  final Map<DateTime, int> dailySeizures; // 일별 발작 횟수
  final double averagePerWeek; // 주당 평균 발작 횟수
  final Duration? averageDuration; // 평균 발작 지속 시간
  final List<DateTime> seizureDates; // 발작 발생 날짜 목록

  SeizureStatistics({
    required this.totalSeizures,
    required this.dailySeizures,
    required this.averagePerWeek,
    this.averageDuration,
    required this.seizureDates,
  });

  /// 발작 감소율 계산 (이전 기간 대비)
  double? calculateReductionRate(SeizureStatistics? previousPeriod) {
    if (previousPeriod == null || previousPeriod.totalSeizures == 0) {
      return null;
    }
    return ((previousPeriod.totalSeizures - totalSeizures) /
            previousPeriod.totalSeizures) *
        100;
  }
}

/// 약 복용 순응도
class MedicationAdherence {
  final int totalDays; // 전체 기간
  final int takenDays; // 복용한 날
  final int missedDays; // 놓친 날
  final double adherenceRate; // 순응도 (%)
  final Map<DateTime, bool> dailyAdherence; // 일별 복용 여부
  final List<String> medications; // 복용 중인 약물 목록

  MedicationAdherence({
    required this.totalDays,
    required this.takenDays,
    required this.missedDays,
    required this.adherenceRate,
    required this.dailyAdherence,
    required this.medications,
  });

  /// 순응도 평가
  String get adherenceLevel {
    if (adherenceRate >= 95) return '우수';
    if (adherenceRate >= 85) return '양호';
    if (adherenceRate >= 75) return '보통';
    return '미흡';
  }
}

/// 식이 요약
class DietSummary {
  final int totalDays; // 전체 기간
  final int recordedDays; // 기록한 날
  final double averageKetoneRatio; // 평균 케톤 비율
  final Map<DateTime, double> dailyKetoneRatios; // 일별 케톤 비율
  final NutritionAverages nutritionAverages; // 평균 영양 성분
  final Map<String, int> ketoStatusCount; // 케토 상태별 횟수
  final double completionRate; // 식단 기록 완성도

  DietSummary({
    required this.totalDays,
    required this.recordedDays,
    required this.averageKetoneRatio,
    required this.dailyKetoneRatios,
    required this.nutritionAverages,
    required this.ketoStatusCount,
    required this.completionRate,
  });

  /// 가장 빈번한 케토 상태
  String get mostFrequentStatus {
    if (ketoStatusCount.isEmpty) return '데이터 없음';
    return ketoStatusCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// 평균 영양 성분
class NutritionAverages {
  final double avgCalories; // 평균 칼로리
  final double avgFat; // 평균 지방 (g)
  final double avgProtein; // 평균 단백질 (g)
  final double avgCarbs; // 평균 탄수화물 (g)
  final double fatPercentage; // 지방 비율 (%)
  final double proteinPercentage; // 단백질 비율 (%)
  final double carbsPercentage; // 탄수화물 비율 (%)

  const NutritionAverages({
    required this.avgCalories,
    required this.avgFat,
    required this.avgProtein,
    required this.avgCarbs,
    required this.fatPercentage,
    required this.proteinPercentage,
    required this.carbsPercentage,
  });
}

/// 보고서 기간 타입
enum ReportPeriodType {
  oneWeek('1주일', 7),
  oneMonth('1개월', 30),
  twoMonths('2개월', 60),
  threeMonths('3개월', 90),
  custom('사용자 지정', 0);

  final String displayName;
  final int days;

  const ReportPeriodType(this.displayName, this.days);
}
