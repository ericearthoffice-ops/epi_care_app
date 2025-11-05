/// 발작 예측 데이터 모델
class SeizurePredictionData {
  final double predictionRate; // 예측 확률 (0-100)
  final EMGData emg; // 근전도
  final ECGData ecg; // 심전도
  final AccelerometerData accelerometer; // 가속도계
  final SleepTimeData sleepTime; // 수면 시간
  final KetoAdherenceData ketoAdherence; // 케톤 식이 순응도
  final MedicationAdherenceData medicationAdherence; // 복약 준수율
  final StressIndexData stressIndex; // 스트레스 지수

  SeizurePredictionData({
    required this.predictionRate,
    required this.emg,
    required this.ecg,
    required this.accelerometer,
    required this.sleepTime,
    required this.ketoAdherence,
    required this.medicationAdherence,
    required this.stressIndex,
  });

  /// Mock 데이터 생성
  factory SeizurePredictionData.mock() {
    return SeizurePredictionData(
      predictionRate: 70,
      emg: EMGData(value: 0.45, unit: 'mV', changeRate: 22, isIncrease: true),
      ecg: ECGData(value: 118, unit: 'bpm', changeRate: 18, isIncrease: true),
      accelerometer: AccelerometerData(value: 2.3, unit: 'g', changeRate: 35, isIncrease: true),
      sleepTime: SleepTimeData(value: 4.8, unit: 'h', changeRate: 36, isIncrease: false),
      ketoAdherence: KetoAdherenceData(value: 82, unit: '%', changeRate: 18, isIncrease: false),
      medicationAdherence: MedicationAdherenceData(value: 85, unit: '%', changeRate: 16, isIncrease: false),
      stressIndex: StressIndexData(value: 78, unit: '/100', changeRate: 28, isIncrease: true),
    );
  }
}

/// 개별 데이터 항목 베이스 클래스
abstract class MedicalDataItem {
  final num? value;
  final String unit;
  final num? changeRate; // 변화율 (%)
  final bool? isIncrease; // 증가: true, 감소: false

  MedicalDataItem({
    required this.value,
    required this.unit,
    required this.changeRate,
    required this.isIncrease,
  });

  String get displayValue => value != null ? '$value $unit' : '-';
  String get displayChange {
    if (changeRate == null || isIncrease == null) return '-';
    return '$changeRate% ${isIncrease! ? '↑' : '↓'}';
  }
}

class EMGData extends MedicalDataItem {
  EMGData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class ECGData extends MedicalDataItem {
  ECGData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class AccelerometerData extends MedicalDataItem {
  AccelerometerData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class SleepTimeData extends MedicalDataItem {
  SleepTimeData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class KetoAdherenceData extends MedicalDataItem {
  KetoAdherenceData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class MedicationAdherenceData extends MedicalDataItem {
  MedicationAdherenceData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}

class StressIndexData extends MedicalDataItem {
  StressIndexData({
    required super.value,
    required super.unit,
    required super.changeRate,
    required super.isIncrease,
  });
}
