import '../models/diet_entry.dart';
import '../models/community_post.dart';

/// 식단 관리 서비스
/// 사용자의 식단 저장, 조회, 삭제 기능 제공
class DietService {
  // 싱글톤 패턴
  static final DietService _instance = DietService._internal();
  factory DietService() => _instance;
  DietService._internal();

  // 메모리 기반 저장소 (나중에 데이터베이스로 변경 가능)
  final Map<String, List<DietEntry>> _dietEntries = {};

  /// 식단 추가
  Future<void> addDietEntry({
    required DateTime date,
    required MealTimeType mealTime,
    required CommunityPost recipe,
  }) async {
    // TODO: 백엔드 API 연동
    final dateKey = _getDateKey(date);

    final entry = DietEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      mealTime: mealTime,
      recipe: recipe,
      createdAt: DateTime.now(),
    );

    if (_dietEntries[dateKey] == null) {
      _dietEntries[dateKey] = [];
    }

    _dietEntries[dateKey]!.add(entry);
  }

  /// 특정 날짜의 식단 조회
  List<DietEntry> getDietEntriesForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return _dietEntries[dateKey] ?? [];
  }

  /// 특정 날짜, 특정 시간대의 식단 조회
  List<DietEntry> getDietEntriesForMealTime(DateTime date, MealTimeType mealTime) {
    final entries = getDietEntriesForDate(date);
    return entries.where((entry) => entry.mealTime == mealTime).toList();
  }

  /// 식단 삭제
  Future<void> deleteDietEntry(String entryId, DateTime date) async {
    // TODO: 백엔드 API 연동
    final dateKey = _getDateKey(date);

    if (_dietEntries[dateKey] != null) {
      _dietEntries[dateKey]!.removeWhere((entry) => entry.id == entryId);
    }
  }

  /// 날짜 키 생성 (YYYY-MM-DD 형식)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
