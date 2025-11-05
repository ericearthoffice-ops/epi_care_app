/// 영양 성분 정보
/// 케톤 식이에서 중요한 영양소 정보를 담는 모델
class NutritionInfo {
  final double calories; // 칼로리 (kcal)
  final double carbs; // 탄수화물 (g)
  final double protein; // 단백질 (g)
  final double fat; // 지방 (g)
  final double? fiber; // 식이섬유 (g) - 선택적

  const NutritionInfo({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.fiber,
  });

  /// 0으로 초기화된 영양 정보
  static const NutritionInfo zero = NutritionInfo(
    calories: 0,
    carbs: 0,
    protein: 0,
    fat: 0,
    fiber: 0,
  );

  /// 영양 정보 합산
  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      calories: calories + other.calories,
      carbs: carbs + other.carbs,
      protein: protein + other.protein,
      fat: fat + other.fat,
      fiber: (fiber ?? 0) + (other.fiber ?? 0),
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      if (fiber != null) 'fiber': fiber,
    };
  }

  /// JSON에서 객체 생성
  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
    );
  }

  /// 순탄수화물 계산 (탄수화물 - 식이섬유)
  double get netCarbs => carbs - (fiber ?? 0);

  @override
  String toString() {
    return 'NutritionInfo(calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, fiber: $fiber)';
  }
}
