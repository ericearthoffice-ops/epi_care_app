import '../models/seizure_record.dart';

/// 발작 기록 서비스
class SeizureService {
  /// 지정된 기간의 발작 기록 가져오기
  List<SeizureRecord> getSeizureRecords({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // TODO: 실제 데이터 소스에서 발작 기록 가져오기
    // 현재는 목업 데이터 반환
    final allRecords = SeizureRecord.mockRecords();

    return allRecords.where((record) {
      return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
