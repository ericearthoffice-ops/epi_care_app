import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diet_entry.dart';
import '../models/community_post.dart';
import '../models/nutrition_info.dart';
import '../services/diet_service.dart';
import '../constants/app_colors.dart';

/// 직접 식단 입력 화면
/// 커뮤니티 없이 개인 식단 정보만 입력
class DirectDietEntryScreen extends StatefulWidget {
  final MealTimeType mealTime;
  final DateTime date;

  const DirectDietEntryScreen({
    super.key,
    required this.mealTime,
    required this.date,
  });

  @override
  State<DirectDietEntryScreen> createState() => _DirectDietEntryScreenState();
}

class _DirectDietEntryScreenState extends State<DirectDietEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // 입력 모드 (true: 영양성분, false: 재료)
  bool _isNutritionMode = true;

  // 입력 컨트롤러
  final _foodNameController = TextEditingController();

  // 영양성분 입력
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();

  // 재료 입력
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    _foodNameController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 재료 추가
  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  /// 재료 삭제
  void _removeIngredient(int index) {
    if (_ingredientControllers.length <= 1) {
      return;
    }
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  /// 저장 처리
  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String contentInfo;
    NutritionInfo? nutritionInfo;

    if (_isNutritionMode) {
      // 영양성분 모드
      final fat = double.tryParse(_fatController.text) ?? 0;
      final protein = double.tryParse(_proteinController.text) ?? 0;
      final carbs = double.tryParse(_carbsController.text) ?? 0;

      // 칼로리 자동 계산 (지방 9kcal/g, 단백질 4kcal/g, 탄수화물 4kcal/g)
      final calories = (fat * 9) + (protein * 4) + (carbs * 4);

      contentInfo =
          '\uC9C0\uBC29: ${fat}g | \uB2E8\uBC31\uC9C8: ${protein}g | \uD0C4\uC218\uD654\uBB3C: ${carbs}g | \uCE74\uB871\uB9AC: ${calories.toStringAsFixed(0)}kcal';

      nutritionInfo = NutritionInfo(
        calories: calories,
        carbs: carbs,
        protein: protein,
        fat: fat,
      );
    } else {
      // 재료 모드
      final ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      contentInfo = '재료: ${ingredients.join(', ')}';
    }

    // 임시 CommunityPost 객체 생성 (실제로는 커뮤니티에 올리지 않음)
    final tempPost = CommunityPost(
      id: 'direct_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user', // TODO: 실제 사용자 ID
      userName: '직접 입력',
      category: CommunityCategory.other,
      title: _foodNameController.text,
      content: contentInfo,
      imageUrls: [],
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
      viewCount: 0,
      nutrition: nutritionInfo,
    );

    // DietService에 추가
    await DietService().addDietEntry(
      date: widget.date,
      mealTime: widget.mealTime,
      recipe: tempPost,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.mealTime.displayName} 식단에 추가되었습니다!'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true); // 성공 플래그와 함께 돌아가기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '식단 직접 입력',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간대 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMealTimeIcon(widget.mealTime),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.mealTime.displayName} 식단',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 음식 이름
              const Text(
                '음식 이름',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodNameController,
                decoration: InputDecoration(
                  hintText: '예: 아보카도 샐러드',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '음식 이름을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 입력 모드 선택 스위치
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNutritionMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isNutritionMode
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.science,
                                size: 20,
                                color: _isNutritionMode
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '영양성분',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _isNutritionMode
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNutritionMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isNutritionMode
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_basket,
                                size: 20,
                                color: !_isNutritionMode
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '재료',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: !_isNutritionMode
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 영양성분 입력 (영양성분 모드일 때만 표시)
              if (_isNutritionMode) ...[
                const Text(
                  '영양 성분',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // 지방
                _buildNutritionField(
                  controller: _fatController,
                  label: '지방 (g)',
                  hint: '0',
                  icon: Icons.water_drop,
                  color: const Color(0xFFFFA726),
                ),

                const SizedBox(height: 16),

                // 단백질
                _buildNutritionField(
                  controller: _proteinController,
                  label: '단백질 (g)',
                  hint: '0',
                  icon: Icons.egg,
                  color: const Color(0xFFEF5350),
                ),

                const SizedBox(height: 16),

                // 탄수화물
                _buildNutritionField(
                  controller: _carbsController,
                  label: '탄수화물 (g)',
                  hint: '0',
                  icon: Icons.grain,
                  color: const Color(0xFF66BB6A),
                ),

                const SizedBox(height: 24),

                // 칼로리 자동 계산 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '칼로리는 자동으로 계산됩니다\n지방 9kcal/g, 단백질·탄수화물 4kcal/g',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 재료 입력 (재료 모드일 때만 표시)
              if (!_isNutritionMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '재료 목록',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 재료 입력 필드들
                ..._ingredientControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: '예: 아보카도 1개',
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_ingredientControllers.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _removeIngredient(index),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // 재료 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '재료 이름과 양을 입력해주세요\n예: 토마토 2개, 올리브유 1큰술',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '식단에 추가',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 영양 성분 입력 필드
  Widget _buildNutritionField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '값을 입력해주세요';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number < 0) {
                    return '올바른 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 시간대별 아이콘
  IconData _getMealTimeIcon(MealTimeType mealTime) {
    switch (mealTime) {
      case MealTimeType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealTimeType.lunch:
        return Icons.wb_sunny;
      case MealTimeType.dinner:
        return Icons.nightlight_round;
    }
  }
}
