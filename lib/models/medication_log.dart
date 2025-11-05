/// 복용 기록 모델
class MedicationLog {
  final String medicationName;
  final DateTime scheduledTime;
  DateTime? actualTime;
  MedicationStatus status;
  int notificationAttempts; // 알람 전송 횟수

  MedicationLog({
    required this.medicationName,
    required this.scheduledTime,
    this.actualTime,
    this.status = MedicationStatus.pending,
    this.notificationAttempts = 0,
  });

  /// JSON 변환 (백엔드 전송용)
  Map<String, dynamic> toJson() {
    return {
      'medicationName': medicationName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'status': status.name,
      'notificationAttempts': notificationAttempts,
    };
  }

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      medicationName: json['medicationName'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      actualTime: json['actualTime'] != null
        ? DateTime.parse(json['actualTime'])
        : null,
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.pending,
      ),
      notificationAttempts: json['notificationAttempts'] ?? 0,
    );
  }
}

/// 복용 상태
enum MedicationStatus {
  pending,    // 대기 중
  taken,      // 복용 완료
  skipped,    // 복용 안함
  missed,     // 놓침 (3회 무응답 후)
}
