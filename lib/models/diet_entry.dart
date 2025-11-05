import 'community_post.dart';

/// 식단 항목
/// 사용자가 달력에 저장한 레시피 정보
class DietEntry {
  final String id;
  final DateTime date;
  final MealTimeType mealTime;
  final CommunityPost recipe;
  final DateTime createdAt;

  DietEntry({
    required this.id,
    required this.date,
    required this.mealTime,
    required this.recipe,
    required this.createdAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealTime': mealTime.name,
      'recipe': recipe.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory DietEntry.fromJson(Map<String, dynamic> json) {
    return DietEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealTime: MealTimeType.values.firstWhere(
        (e) => e.name == json['mealTime'],
      ),
      recipe: CommunityPost.fromJson(json['recipe'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// 식사 시간대
enum MealTimeType {
  breakfast('아침'),
  lunch('점심'),
  dinner('저녁');

  final String displayName;
  const MealTimeType(this.displayName);
}
