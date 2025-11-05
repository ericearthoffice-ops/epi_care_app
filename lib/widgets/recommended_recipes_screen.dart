import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/format_utils.dart';
import 'meal_time_selection_screen.dart';
import 'community_detail_screen.dart';
import '../models/nutrition_info.dart';

/// 추천 레시피 목록 화면
/// 선택한 카테고리의 레시피를 좋아요/저장 많은 순으로 표시
class RecommendedRecipesScreen extends StatefulWidget {
  final DateTime selectedDate;
  final MealTime mealTime;
  final CommunityCategory category;

  const RecommendedRecipesScreen({
    super.key,
    required this.selectedDate,
    required this.mealTime,
    required this.category,
  });

  @override
  State<RecommendedRecipesScreen> createState() => _RecommendedRecipesScreenState();
}

class _RecommendedRecipesScreenState extends State<RecommendedRecipesScreen> {
  List<CommunityPost> _recommendedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedRecipes();
  }

  /// 추천 레시피 로드
  Future<void> _loadRecommendedRecipes() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: 백엔드 API 연동
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock 데이터 생성 후 필터링 및 정렬
    final allPosts = _generateMockPosts();

    // 선택한 카테고리만 필터링
    final filteredPosts = allPosts
        .where((post) => post.category == widget.category)
        .toList();

    // 좋아요 + 댓글 수 기준으로 정렬 (인기순)
    filteredPosts.sort((a, b) {
      final scoreA = a.likeCount + (a.commentCount * 2); // 댓글에 가중치
      final scoreB = b.likeCount + (b.commentCount * 2);
      return scoreB.compareTo(scoreA);
    });

    setState(() {
      _recommendedPosts = filteredPosts;
      _isLoading = false;
    });
  }

  /// Mock 데이터 생성
  List<CommunityPost> _generateMockPosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: '1',
        userId: 'user001',
        userName: '김민지',
        title: '케토 야채볶음 만드는 법 쉽게',
        content: '양배추, 숙주, 당근을 활용한 케토 야채볶음입니다. 탄수화물을 최소화하면서도 맛있게 만들 수 있어요!',
        category: CommunityCategory.korean,
        imageUrls: ['https://example.com/image1.jpg'],
        createdAt: now.subtract(const Duration(hours: 2)),
        likeCount: 45,
        commentCount: 12,
        viewCount: 234,
        nutrition: const NutritionInfo(
          calories: 320,
          carbs: 8,
          protein: 12,
          fat: 18,
        ),
      ),
      CommunityPost(
        id: '2',
        userId: 'user002',
        userName: '안민혁',
        title: '치킨 강정 스크램블 에그',
        content: '아이가 좋아하는 스크램블 에그를 케토 버전으로 만들어봤어요. 치즈와 함께 먹으면 정말 맛있습니다!',
        category: CommunityCategory.korean,
        imageUrls: ['https://example.com/image2.jpg'],
        createdAt: now.subtract(const Duration(hours: 5)),
        likeCount: 67,
        commentCount: 18,
        viewCount: 456,
        nutrition: const NutritionInfo(
          calories: 310,
          carbs: 9,
          protein: 18,
          fat: 17,
        ),
      ),
      CommunityPost(
        id: '3',
        userId: 'user003',
        userName: '박서연',
        title: '한식 된장찌개',
        content: '저탄수화물 된장찌개입니다. 두부와 야채를 듬뿍 넣어서 영양도 가득!',
        category: CommunityCategory.korean,
        imageUrls: ['https://example.com/image3.jpg'],
        createdAt: now.subtract(const Duration(hours: 8)),
        likeCount: 89,
        commentCount: 25,
        viewCount: 678,
        nutrition: const NutritionInfo(
          calories: 295,
          carbs: 7,
          protein: 15,
          fat: 16,
        ),
      ),
      CommunityPost(
        id: '4',
        userId: 'user004',
        userName: '이준호',
        title: '케토 짜장면 만들기',
        content: '곤약면으로 만든 케토 짜장면입니다. 일반 짜장면과 거의 비슷한 맛!',
        category: CommunityCategory.chinese,
        imageUrls: ['https://example.com/image4.jpg'],
        createdAt: now.subtract(const Duration(days: 1)),
        likeCount: 123,
        commentCount: 34,
        viewCount: 890,
        nutrition: const NutritionInfo(
          calories: 330,
          carbs: 12,
          protein: 19,
          fat: 21,
        ),
      ),
      CommunityPost(
        id: '5',
        userId: 'user001',
        userName: '김민지',
        title: '양식 스테이크 샐러드',
        content: '소고기 스테이크와 각종 야채를 곁들인 케토 샐러드입니다.',
        category: CommunityCategory.western,
        imageUrls: ['https://example.com/image5.jpg'],
        createdAt: now.subtract(const Duration(days: 2)),
        likeCount: 56,
        commentCount: 15,
        viewCount: 345,
        nutrition: const NutritionInfo(
          calories: 360,
          carbs: 5,
          protein: 25,
          fat: 30,
        ),
      ),
      CommunityPost(
        id: '6',
        userId: 'user005',
        userName: '최지우',
        title: '일식 소바 대체 메뉴',
        content: '곤약 소바로 만든 저탄수 일식 요리입니다.',
        category: CommunityCategory.japanese,
        imageUrls: ['https://example.com/image6.jpg'],
        createdAt: now.subtract(const Duration(days: 3)),
        likeCount: 134,
        commentCount: 28,
        viewCount: 834,
        nutrition: const NutritionInfo(
          calories: 300,
          carbs: 7,
          protein: 20,
          fat: 22,
        ),
      ),
      CommunityPost(
        id: '7',
        userId: 'user006',
        userName: '정수민',
        title: '케토 비빔밥',
        content: '곤약밥으로 만든 건강한 케토 비빔밥입니다!',
        category: CommunityCategory.korean,
        imageUrls: ['https://example.com/image7.jpg'],
        createdAt: now.subtract(const Duration(days: 4)),
        likeCount: 78,
        commentCount: 22,
        viewCount: 567,
        nutrition: const NutritionInfo(
          calories: 310,
          carbs: 9,
          protein: 16,
          fat: 20,
        ),
      ),
      CommunityPost(
        id: '8',
        userId: 'user007',
        userName: '강태양',
        title: '중식 깐풍기 케토 버전',
        content: '닭가슴살로 만든 케토 깐풍기입니다.',
        category: CommunityCategory.chinese,
        imageUrls: ['https://example.com/image8.jpg'],
        createdAt: now.subtract(const Duration(days: 5)),
        likeCount: 95,
        commentCount: 19,
        viewCount: 723,
        nutrition: const NutritionInfo(
          calories: 340,
          carbs: 10,
          protein: 18,
          fat: 23,
        ),
      ),
    ];
  }

  /// 레시피 선택
  void _selectRecipe(CommunityPost post) {
    // TODO: 선택한 레시피를 달력에 추가하는 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${post.title}을(를) ${widget.mealTime.displayName} 식단으로 추가했습니다!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // 달력 화면으로 돌아가기
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${widget.category.displayName} 추천 레시피',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _recommendedPosts.isEmpty
              ? _buildEmptyState()
              : _buildRecipeList(),
    );
  }

  /// 레시피 목록
  Widget _buildRecipeList() {
    return Column(
      children: [
        // 헤더 정보
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppStyles.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '인기 레시피',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '좋아요가 많은 순서로 정렬되었습니다',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // 레시피 카드 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: _recommendedPosts.length,
            itemBuilder: (context, index) {
              final post = _recommendedPosts[index];
              return _buildRecipeCard(post, index);
            },
          ),
        ),
      ],
    );
  }

  /// 레시피 카드
  Widget _buildRecipeCard(CommunityPost post, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          // 상세 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommunityDetailScreen(post: post),
            ),
          );
        },
        borderRadius: AppStyles.borderRadiusMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            _buildPostImage(post, index),

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 순위 뱃지
                  if (index < 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRankColor(index).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRankColor(index).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: _getRankColor(index),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TOP ${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getRankColor(index),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // 제목
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 내용 미리보기
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 하단 정보 및 추가 버튼
                  Row(
                    children: [
                      // 작성자
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.userName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 좋아요 수
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 댓글 수
                      Icon(
                        Icons.chat_bubble,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const Spacer(),

                      // 추가 버튼
                      ElevatedButton.icon(
                        onPressed: () => _selectRecipe(post),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 게시글 이미지
  Widget _buildPostImage(CommunityPost post, int index) {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FormatUtils.getCommunityCategoryColor(post.category),
                FormatUtils.getCommunityCategoryColor(post.category)
                    .withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        // 순위 오버레이 (TOP 3만)
        if (index < 3)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(index),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 순위별 색상
  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // 금색
      case 1:
        return const Color(0xFFC0C0C0); // 은색
      case 2:
        return const Color(0xFFCD7F32); // 동색
      default:
        return AppColors.primary;
    }
  }

  /// 빈 상태 화면
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '추천할 레시피가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 카테고리를 선택해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
