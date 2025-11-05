import '../models/medical_report.dart';
import '../models/nutrition_info.dart';
import 'seizure_service.dart';
import 'diet_service.dart';

/// 의료 보고서 데이터 수집 서비스
class MedicalReportService {
  final SeizureService _seizureService = SeizureService();
  final DietService _dietService = DietService();

  /// 지정된 기간의 의료 보고서 데이터 생성
  Future<MedicalReport> generateReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 발작 통계 수집
    final seizureStats = await _collectSeizureStatistics(startDate, endDate);

    // 약 복용 순응도 수집
    final medicationAdherence = await _collectMedicationAdherence(startDate, endDate);

    // 식이 요약 수집
    final dietSummary = await _collectDietSummary(startDate, endDate);

    return MedicalReport(
      startDate: startDate,
      endDate: endDate,
      seizureStats: seizureStats,
      medicationAdherence: medicationAdherence,
      dietSummary: dietSummary,
    );
  }

  /// 발작 통계 수집
  Future<SeizureStatistics> _collectSeizureStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // 발작 기록 가져오기
    final seizures = _seizureService.getSeizureRecords(
      startDate: startDate,
      endDate: endDate,
    );

    final dailySeizures = <DateTime, int>{};
    final seizureDates = <DateTime>[];

    for (var seizure in seizures) {
      final date = DateTime(
        seizure.date.year,
        seizure.date.month,
        seizure.date.day,
      );
      dailySeizures[date] = (dailySeizures[date] ?? 0) + 1;
      seizureDates.add(seizure.date);
    }

    final totalDays = endDate.difference(startDate).inDays + 1;
    final averagePerWeek = (seizures.length / totalDays) * 7;

    Duration? averageDuration;
    if (seizures.isNotEmpty) {
      final totalSeconds = seizures
          .map((s) => s.duration.inSeconds)
          .reduce((a, b) => a + b);
      averageDuration = Duration(seconds: totalSeconds ~/ seizures.length);
    }

    return SeizureStatistics(
      totalSeizures: seizures.length,
      dailySeizures: dailySeizures,
      averagePerWeek: averagePerWeek,
      averageDuration: averageDuration,
      seizureDates: seizureDates,
    );
  }

  /// 약 복용 순응도 수집
  Future<MedicationAdherence> _collectMedicationAdherence(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // TODO: 실제 데이터 소스에서 약 복용 기록 가져오기
    // 임시 데이터
    final totalDays = endDate.difference(startDate).inDays + 1;
    final dailyAdherence = <DateTime, bool>{};

    // 테스트용: 90% 순응도로 임시 데이터 생성
    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      dailyAdherence[date] = i % 10 != 0; // 10일 중 9일 복용
    }

    final takenDays = dailyAdherence.values.where((taken) => taken).length;
    final missedDays = totalDays - takenDays;
    final adherenceRate = (takenDays / totalDays) * 100;

    return MedicationAdherence(
      totalDays: totalDays,
      takenDays: takenDays,
      missedDays: missedDays,
      adherenceRate: adherenceRate,
      dailyAdherence: dailyAdherence,
      medications: ['레비티라세탐', '토피라메이트'], // TODO: 실제 약물 목록
    );
  }

  /// 식이 요약 수집
  Future<DietSummary> _collectDietSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final totalDays = endDate.difference(startDate).inDays + 1;
    final dailyKetoneRatios = <DateTime, double>{};
    final ketoStatusCount = <String, int>{};

    double totalKetoneRatio = 0;
    int ratioCount = 0;

    double totalCalories = 0;
    double totalFat = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    int nutritionCount = 0;

    int recordedDays = 0;

    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      final entries = _dietService.getDietEntriesForDate(date);

      if (entries.isNotEmpty) {
        recordedDays++;

        // 하루 영양성분 합산
        var dayNutrition = NutritionInfo.zero;
        for (var entry in entries) {
          if (entry.recipe.nutrition != null) {
            dayNutrition = dayNutrition + entry.recipe.nutrition!;
          }
        }

        if (dayNutrition.calories > 0) {
          nutritionCount++;
          totalCalories += dayNutrition.calories;
          totalFat += dayNutrition.fat;
          totalProtein += dayNutrition.protein;
          totalCarbs += dayNutrition.carbs;

          // 케톤 비율 계산
          final denominator = dayNutrition.protein + dayNutrition.carbs;
          if (denominator > 0) {
            final ratio = dayNutrition.fat / denominator;
            dailyKetoneRatios[date] = ratio;
            totalKetoneRatio += ratio;
            ratioCount++;

            // 케토 상태 분류
            String status;
            if (ratio > 5.0) {
              status = '경고';
            } else if (ratio > 4.0) {
              status = '주의';
            } else if (ratio >= 2.5) {
              status = '완벽';
            } else if (ratio >= 2.0) {
              status = '양호';
            } else {
              status = '미흡';
            }
            ketoStatusCount[status] = (ketoStatusCount[status] ?? 0) + 1;
          }
        }
      }
    }

    final avgKetoneRatio = ratioCount > 0 ? totalKetoneRatio / ratioCount : 0.0;
    final completionRate = (recordedDays / totalDays) * 100;

    final nutritionAverages = nutritionCount > 0
        ? NutritionAverages(
            avgCalories: totalCalories / nutritionCount,
            avgFat: totalFat / nutritionCount,
            avgProtein: totalProtein / nutritionCount,
            avgCarbs: totalCarbs / nutritionCount,
            fatPercentage: totalCalories > 0 ? ((totalFat * 9) / totalCalories) * 100 : 0,
            proteinPercentage: totalCalories > 0 ? ((totalProtein * 4) / totalCalories) * 100 : 0,
            carbsPercentage: totalCalories > 0 ? ((totalCarbs * 4) / totalCalories) * 100 : 0,
          )
        : const NutritionAverages(
            avgCalories: 0,
            avgFat: 0,
            avgProtein: 0,
            avgCarbs: 0,
            fatPercentage: 0,
            proteinPercentage: 0,
            carbsPercentage: 0,
          );

    return DietSummary(
      totalDays: totalDays,
      recordedDays: recordedDays,
      averageKetoneRatio: avgKetoneRatio,
      dailyKetoneRatios: dailyKetoneRatios,
      nutritionAverages: nutritionAverages,
      ketoStatusCount: ketoStatusCount,
      completionRate: completionRate,
    );
  }
}
