import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../models/nutrition_info.dart';
import '../services/community_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/format_utils.dart';
import '../widgets/common/category_chip.dart';
import 'community_detail_screen.dart';
import 'community_write_screen.dart';
import 'meal_time_selection_screen.dart';
import 'loading_screen.dart';

/// 정렬 방식 enum
enum SortOrder {
  popular('인기순'),
  saved('저장순'),
  latest('최신순'),
  comments('댓글순');

  final String displayName;
  const SortOrder(this.displayName);
}

/// 커뮤니티 목록 화면
/// 케톤 식이 레시피 및 팁 공유 커뮤니티
class CommunityListScreen extends StatefulWidget {
  final CommunityCategory? initialCategory;
  final SortOrder initialSortOrder;
  final MealTime? selectedMealTime; // 식단 추가용 시간대 (optional)
  final DateTime? selectedDate; // 식단 추가용 날짜 (optional)

  const CommunityListScreen({
    super.key,
    this.initialCategory,
    this.initialSortOrder = SortOrder.popular,
    this.selectedMealTime,
    this.selectedDate,
  });

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CommunityCategory? _selectedCategory; // null이면 전체 보기
  late SortOrder _currentSortOrder;
  List<CommunityPost> _communityPosts = [];
  bool _isLoading = true;

  // TODO: 실제 사용자 ID는 인증 시스템에서 가져와야 함
  final String _currentUserId = 'user001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.initialCategory;
    _currentSortOrder = widget.initialSortOrder;
    _loadCommunityPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 커뮤니티 게시글 로드
  Future<void> _loadCommunityPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 선택된 카테고리 결정 (전체는 null)
      CommunityCategory? selectedCategory;
      if (_tabController.index > 0) {
        selectedCategory = CommunityCategory.values[_tabController.index - 1];
      }

      // 백엔드 API 호출
      final posts = await CommunityService.fetchPosts(
        category: selectedCategory,
        sort: _currentSortOrder.name,
      );

      setState(() {
        _communityPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('커뮤니티 게시글 로드 실패: $e');

      // 에러 발생 시 Mock 데이터로 대체 (개발 중 fallback)
      if (mounted) {
        setState(() {
          _communityPosts = _generateMockPosts();
          _isLoading = false;
        });

        // 사용자에게 에러 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('서버 연결 실패. Mock 데이터를 표시합니다.\n($e)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '재시도',
              textColor: Colors.white,
              onPressed: () {
                _loadCommunityPosts();
              },
            ),
          ),
        );
      }
    } finally {
      // 로딩 상태를 확실히 false로 설정
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          calories: 285,
          carbs: 10,
          protein: 17,
          fat: 15,
        ),
      ),
      CommunityPost(
        id: '3',
        userId: 'user003',
        userName: '박서연',
        title: '한식 된장찌개 중식',
        content: '저탄수화물 된장찌개입니다. 두부와 야채를 듬뿍 넣어서 영양도 가득!',
        category: CommunityCategory.korean,
        imageUrls: ['https://example.com/image3.jpg'],
        createdAt: now.subtract(const Duration(hours: 8)),
        likeCount: 89,
        commentCount: 25,
        viewCount: 678,
        nutrition: const NutritionInfo(
          calories: 265,
          carbs: 9,
          protein: 14,
          fat: 14,
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
          calories: 310,
          carbs: 11,
          protein: 16,
          fat: 19,
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
          calories: 350,
          carbs: 6,
          protein: 24,
          fat: 28,
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
        likeCount: 34,
        commentCount: 8,
        viewCount: 234,
        nutrition: const NutritionInfo(
          calories: 280,
          carbs: 7,
          protein: 15,
          fat: 18,
        ),
      ),
    ];
  }

  /// 정렬 함수
  List<CommunityPost> _sortPosts(List<CommunityPost> posts) {
    final sortedPosts = List<CommunityPost>.from(posts);

    switch (_currentSortOrder) {
      case SortOrder.popular:
        // 인기순: 좋아요 + (댓글 수 × 2)
        sortedPosts.sort((a, b) {
          final scoreA = a.likeCount + (a.commentCount * 2);
          final scoreB = b.likeCount + (b.commentCount * 2);
          return scoreB.compareTo(scoreA);
        });
        break;
      case SortOrder.saved:
        // 저장순: 좋아요 수로 대체 (실제 저장 기능 추가 시 변경)
        sortedPosts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case SortOrder.latest:
        // 최신순
        sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.comments:
        // 댓글순
        sortedPosts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
        break;
    }

    return sortedPosts;
  }

  /// 카테고리별 필터링된 목록 (전체 글)
  List<CommunityPost> get _filteredPosts {
    List<CommunityPost> posts;
    if (_selectedCategory == null) {
      posts = _communityPosts;
    } else {
      posts = _communityPosts
          .where((post) => post.category == _selectedCategory)
          .toList();
    }
    return _sortPosts(posts);
  }

  /// 내 글만 필터링
  List<CommunityPost> get _myPosts {
    var posts = _communityPosts.where((post) => post.userId == _currentUserId).toList();
    if (_selectedCategory != null) {
      posts = posts.where((post) => post.category == _selectedCategory).toList();
    }
    return _sortPosts(posts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: '홈'),
            Tab(text: '내 글'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 카테고리 필터
          _buildCategoryFilter(),

          // 탭 뷰
          Expanded(
            child: _isLoading
                ? const LoadingScreen()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // 홈 탭
                      _buildPostList(_filteredPosts),
                      // 내 글 탭
                      _buildPostList(_myPosts),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 글 작성 화면으로 이동
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CommunityWriteScreen(),
            ),
          );

          // 게시글이 작성되었으면 목록 새로고침
          if (result == true && mounted) {
            _loadCommunityPosts();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 카테고리 필터
  Widget _buildCategoryFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          // 정렬 옵션
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.sort, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              DropdownButton<SortOrder>(
                value: _currentSortOrder,
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                items: SortOrder.values.map((order) {
                  return DropdownMenuItem<SortOrder>(
                    value: order,
                    child: Text(order.displayName),
                  );
                }).toList(),
                onChanged: (SortOrder? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentSortOrder = newValue;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 카테고리 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryChip(
                  label: '전체',
                  isSelected: _selectedCategory == null,
                  count: _tabController.index == 0
                      ? _communityPosts.length
                      : _myPosts.length,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...CommunityCategory.values.map((category) {
                  final count = _tabController.index == 0
                      ? _communityPosts
                          .where((post) => post.category == category)
                          .length
                      : _myPosts
                          .where((post) => post.category == category)
                          .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: category.displayName,
                      isSelected: _selectedCategory == category,
                      count: count,
                      onTap: () => setState(() => _selectedCategory = category),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 게시글 목록
  Widget _buildPostList(List<CommunityPost> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCommunityPosts,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(posts[index]);
        },
      ),
    );
  }

  /// 게시글 카드
  Widget _buildPostCard(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommunityDetailScreen(
                post: post,
                selectedMealTime: widget.selectedMealTime,
                selectedDate: widget.selectedDate,
              ),
            ),
          );
        },
        borderRadius: AppStyles.borderRadiusMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 (있는 경우)
            if (post.imageUrls.isNotEmpty) _buildPostImage(post),

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FormatUtils.getCommunityCategoryColor(post.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FormatUtils.getCommunityCategoryColor(post.category)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      post.category.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FormatUtils.getCommunityCategoryColor(post.category),
                      ),
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

                  // 하단 정보
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
                        Icons.favorite_border,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 댓글 수
                      Icon(
                        Icons.chat_bubble_outline,
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
                      const SizedBox(width: 12),

                      // 조회수
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.viewCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const Spacer(),

                      // 작성 시간
                      Text(
                        FormatUtils.getTimeAgoText(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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
  Widget _buildPostImage(CommunityPost post) {
    return Container(
      height: 200,
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
    );
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
            _tabController.index == 0 ? '아직 게시글이 없습니다' : '작성한 글이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tabController.index == 0
                ? '첫 번째 레시피를 공유해보세요!'
                : '케토 레시피를 공유해보세요!',
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
