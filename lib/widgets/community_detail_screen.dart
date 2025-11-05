import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../models/diet_entry.dart';
import '../models/nutrition_info.dart';
import '../constants/app_colors.dart';
import '../utils/format_utils.dart';
import '../services/diet_service.dart';
import 'meal_time_selection_screen.dart';

/// 커뮤니티 게시글 상세 화면
/// 레시피 전체 정보 및 댓글 기능
class CommunityDetailScreen extends StatefulWidget {
  final CommunityPost post;
  final MealTime? selectedMealTime; // 식단 추가용 시간대 (optional)
  final DateTime? selectedDate; // 식단 추가용 날짜 (optional)

  const CommunityDetailScreen({
    super.key,
    required this.post,
    this.selectedMealTime,
    this.selectedDate,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<_Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _loadMockComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Mock 댓글 로드
  void _loadMockComments() {
    setState(() {
      _comments.addAll([
        _Comment(
          userName: '박서연',
          content: '아이가 정말 맛있게 먹었어요! 감사합니다 😊',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        _Comment(
          userName: '이준호',
          content: '재료 구하기 쉬워서 좋네요. 내일 바로 만들어봐야겠어요!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ]);
    });
  }

  /// 좋아요 토글
  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
    // TODO: 백엔드 API 연동
  }

  /// 내 식단으로 복사
  void _copyToMyDiet() async {
    MealTimeType? selectedMealTime;

    // 이미 시간대가 선택되어 있으면 다이얼로그 없이 바로 사용
    if (widget.selectedMealTime != null) {
      // MealTime -> MealTimeType 변환
      selectedMealTime = _convertMealTime(widget.selectedMealTime!);
    } else {
      // 시간대 선택 다이얼로그 표시
      selectedMealTime = await showDialog<MealTimeType>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            '식사 시간 선택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: MealTimeType.values.map((mealTime) {
              return ListTile(
                leading: Icon(
                  _getMealTimeIcon(mealTime),
                  color: _getMealTimeColor(mealTime),
                ),
                title: Text(mealTime.displayName),
                onTap: () => Navigator.of(context).pop(mealTime),
              );
            }).toList(),
          ),
        ),
      );
    }

    if (selectedMealTime != null && mounted) {
      // 선택된 날짜 또는 오늘 날짜로 식단 저장
      final targetDate = widget.selectedDate ?? DateTime.now();
      await DietService().addDietEntry(
        date: targetDate,
        mealTime: selectedMealTime,
        recipe: widget.post,
      );

      if (mounted) {
        // SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedMealTime.displayName} 식단에 추가되었습니다!'),
            duration: const Duration(seconds: 2),
          ),
        );

        // 식이/달력 화면으로 돌아가기 (모든 네비게이션 스택 정리)
        // DietCalendarScreen까지 모든 화면 pop
        Navigator.of(context).popUntil((route) {
          // 첫 번째 route (DietCalendarScreen)까지 pop
          return route.isFirst;
        });
      }
    }
  }

  /// MealTime을 MealTimeType으로 변환
  MealTimeType _convertMealTime(MealTime mealTime) {
    switch (mealTime) {
      case MealTime.breakfast:
        return MealTimeType.breakfast;
      case MealTime.lunch:
        return MealTimeType.lunch;
      case MealTime.dinner:
        return MealTimeType.dinner;
    }
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

  /// 시간대별 색상
  Color _getMealTimeColor(MealTimeType mealTime) {
    switch (mealTime) {
      case MealTimeType.breakfast:
        return const Color(0xFFFFB74D); // 주황색
      case MealTimeType.lunch:
        return const Color(0xFFFDD835); // 노란색
      case MealTimeType.dinner:
        return const Color(0xFF5C6BC0); // 보라색
    }
  }

  /// 댓글 작성
  void _submitComment() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _comments.insert(
        0,
        _Comment(
          userName: '나', // TODO: 실제 사용자 이름
          content: _commentController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
    });

    // TODO: 백엔드 API 연동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // 내 식단으로 복사 버튼
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: '내 식단으로 복사',
            onPressed: _copyToMyDiet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지
            _buildMainImage(),

            // 제목 및 기본 정보
            _buildHeader(),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            // 재료
            _buildIngredientsSection(),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            // 조리 순서
            _buildCookingStepsSection(),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            // Nutrition Facts
            _buildNutritionSection(),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            // 댓글 섹션
            _buildCommentsSection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      // 하단 액션 바
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// 메인 이미지
  Widget _buildMainImage() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FormatUtils.getCommunityCategoryColor(widget.post.category),
            FormatUtils.getCommunityCategoryColor(
              widget.post.category,
            ).withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// 헤더 (제목, 작성자, 카테고리)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FormatUtils.getCommunityCategoryColor(
                widget.post.category,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FormatUtils.getCommunityCategoryColor(
                  widget.post.category,
                ).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              widget.post.category.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: FormatUtils.getCommunityCategoryColor(
                  widget.post.category,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 제목
          Text(
            widget.post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // 설명
          Text(
            widget.post.content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          // 작성자 정보
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.getTimeAgoText(widget.post.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 재료 섹션
  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재료',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildIngredientsTable(),
        ],
      ),
    );
  }

  /// 재료 표
  Widget _buildIngredientsTable() {
    // Mock 재료 데이터
    final ingredients = [
      {'name': '양배추', 'amount': '150g'},
      {'name': '당근', 'amount': '50g'},
      {'name': '숙주', 'amount': '100g'},
      {'name': '계란', 'amount': '2개'},
      {'name': '올리브유', 'amount': '1큰술'},
      {'name': '소금', 'amount': '약간'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    '재료명',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '계량',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 재료 목록
          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isLast = index == ingredients.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      ingredient['name']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ingredient['amount']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 조리 순서 섹션
  Widget _buildCookingStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '조리순서',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCookingSteps(),
        ],
      ),
    );
  }

  /// 조리 순서 목록
  Widget _buildCookingSteps() {
    // Mock 조리 순서
    final steps = [
      '양배추, 당근, 숙주는 깨끗이 씻어 물기를 제거한 후 먹기 좋은 크기로 썰어주세요.',
      '계란은 그릇에 풀어 소금으로 간을 맞춰주세요.',
      '팬에 올리브유를 두르고 중불에서 계란을 부드럽게 스크램블 해주세요.',
      '같은 팬에 야채를 넣고 살짝 볶다가 소금으로 간을 맞춰주세요.',
      '접시에 야채를 담고 그 위에 스크램블 에그를 올려 완성합니다.',
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 설명
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Nutrition Facts 섹션
  Widget _buildNutritionSection() {
    final NutritionInfo? info = widget.post.nutrition;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Facts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: info != null
                ? Column(
                    children: [
                      _buildNutritionRow(
                        'Calories',
                        '${info.calories.toStringAsFixed(0)} kcal',
                        AppColors.categoryDiet,
                      ),
                      const SizedBox(height: 12),
                      _buildNutritionRow(
                        'Carbs',
                        _formatNutrition(info.carbs),
                        AppColors.categoryDiet,
                      ),
                      const SizedBox(height: 12),
                      _buildNutritionRow(
                        'Protein',
                        _formatNutrition(info.protein),
                        AppColors.categoryMedication,
                      ),
                      const SizedBox(height: 12),
                      _buildNutritionRow(
                        'Fat',
                        _formatNutrition(info.fat),
                        AppColors.categorySeizure,
                      ),
                      const SizedBox(height: 12),
                      _buildNutritionRow(
                        'Ketone Ratio',
                        _formatKetone(info),
                        AppColors.primary,
                      ),
                    ],
                  )
                : const Text(
                    '등록된 Nutrition Facts가 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatNutrition(double value) {
    if (value == 0) return '0 g';
    if (value < 1) return '${value.toStringAsFixed(2)} g';
    if (value < 10) return '${value.toStringAsFixed(1)} g';
    return '${value.toStringAsFixed(0)} g';
  }

  String _formatKetone(NutritionInfo info) {
    final double denominator = info.protein + info.carbs;
    if (info.fat <= 0 || denominator <= 0) return '-';
    final double ratio = info.fat / denominator;
    return '${ratio.toStringAsFixed(2)}:1';
  }

  /// 댓글 섹션
  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '댓글',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '${_comments.length}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 댓글 목록
          if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  '첫 댓글을 남겨보세요!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ..._comments.map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  /// 댓글 아이템
  Widget _buildCommentItem(_Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                FormatUtils.getTimeAgoText(comment.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 액션 바
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 좋아요 버튼
            InkWell(
              onTap: _toggleLike,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likeCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isLiked ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Comment
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 1,
              ),
            ),

            const SizedBox(width: 8),

            // 전송 버튼
            IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send),
              color: AppColors.primary,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// 댓글 모델 (간단한 내부 클래스)
class _Comment {
  final String userName;
  final String content;
  final DateTime createdAt;

  _Comment({
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}
