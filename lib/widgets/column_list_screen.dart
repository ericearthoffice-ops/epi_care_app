import 'package:flutter/material.dart';
import '../models/column_post.dart';
import '../models/qna_post.dart'; // ExpertType 사용을 위해 필요
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/format_utils.dart';
import '../widgets/common/category_chip.dart';
import 'column_detail_screen.dart';

/// 칼럼 목록 화면
/// 전문가가 작성한 의료 정보 칼럼을 카테고리별로 확인할 수 있는 화면
class ColumnListScreen extends StatefulWidget {
  const ColumnListScreen({super.key});

  @override
  State<ColumnListScreen> createState() => _ColumnListScreenState();
}

class _ColumnListScreenState extends State<ColumnListScreen> {
  ColumnCategory? _selectedCategory; // null이면 전체 보기
  List<ColumnPost> _columnPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColumnPosts();
  }

  /// 칼럼 목록 로드 (Mock 데이터)
  Future<void> _loadColumnPosts() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: 백엔드 API 연동
    await Future.delayed(const Duration(seconds: 1));

    final mockPosts = _generateMockPosts();

    setState(() {
      _columnPosts = mockPosts;
      _isLoading = false;
    });
  }

  /// Mock 데이터 생성
  List<ColumnPost> _generateMockPosts() {
    final now = DateTime.now();
    return [
      ColumnPost(
        id: '1',
        authorId: 'expert001',
        authorName: '김태현',
        authorType: ExpertType.pediatricNeurologist,
        authorTitle: '서울대병원 소아신경과 교수',
        title: '발작이 일어났을 때, 부모가 꼭 알아야 할 5가지',
        summary:
            '갑작스러운 발작 상황에서 당황하지 않고 대처할 수 있도록 필수 응급처치 방법과 주의사항을 소개합니다.',
        content: '''
# 발작이 일어났을 때, 부모가 꼭 알아야 할 5가지

발작은 예고 없이 찾아옵니다. 부모님들이 가장 두려워하는 순간이지만, 올바른 대처법을 알고 있다면 아이를 안전하게 보호할 수 있습니다.

## 1. 침착함을 유지하세요

발작을 목격하면 당황스럽지만, 부모의 침착한 대처가 가장 중요합니다.

## 2. 안전한 공간 확보

아이 주변의 위험한 물건을 치우고, 머리를 보호해주세요.

## 3. 시간을 측정하세요

발작 지속 시간을 측정하는 것이 매우 중요합니다. 5분 이상 지속되면 119에 연락하세요.

## 4. 억지로 막지 마세요

입에 무언가를 넣거나, 몸을 억지로 누르지 마세요.

## 5. 발작 후 회복

발작이 멈춘 후 옆으로 눕혀 기도를 확보하고, 의식이 돌아올 때까지 지켜봐주세요.
        ''',
        category: ColumnCategory.seizureInfo,
        thumbnailUrl: '',
        tags: ['응급처치', '발작대응', '부모가이드'],
        createdAt: now.subtract(const Duration(days: 2)),
        viewCount: 1245,
        likeCount: 89,
        bookmarkCount: 156,
        isFeatured: true,
      ),
      ColumnPost(
        id: '2',
        authorId: 'expert002',
        authorName: '이서영',
        authorType: ExpertType.pharmacist,
        authorTitle: '세브란스병원 약제부 약사',
        title: '항발작제 복용, 이것만은 꼭 지키세요',
        summary: '항발작제의 효과를 최대화하고 부작용을 최소화하기 위한 올바른 복용 방법을 알려드립니다.',
        content: '''
# 항발작제 복용, 이것만은 꼭 지키세요

항발작제는 정확한 시간에 꾸준히 복용하는 것이 가장 중요합니다.

## 복약 시간 지키기

매일 같은 시간에 복용하는 것이 혈중 농도를 일정하게 유지하는 핵심입니다.

## 임의로 중단하지 않기

증상이 좋아져도 의사와 상담 없이 약을 끊으면 안 됩니다.
        ''',
        category: ColumnCategory.medicationGuide,
        thumbnailUrl: '',
        tags: ['항발작제', '복약지도', '주의사항'],
        createdAt: now.subtract(const Duration(days: 5)),
        viewCount: 892,
        likeCount: 67,
        bookmarkCount: 103,
        isFeatured: true,
      ),
      ColumnPost(
        id: '3',
        authorId: 'expert003',
        authorName: '박민지',
        authorType: ExpertType.dietitian,
        authorTitle: '아산병원 영양팀 임상영양사',
        title: '케토제닉 식단 시작하기: 초보 부모 가이드',
        summary: '케토제닉 식단의 기본 원리부터 실전 레시피까지, 처음 시작하는 가족을 위한 완벽 가이드입니다.',
        content: '''
# 케토제닉 식단 시작하기

케토제닉 식단은 뇌전증 치료에 효과적인 식이요법입니다.

## 케토제닉 식단이란?

고지방, 저탄수화물 식단으로 몸이 케톤체를 에너지원으로 사용하게 만듭니다.

## 시작 전 준비사항

의료진과 충분한 상담 후 시작하는 것이 중요합니다.
        ''',
        category: ColumnCategory.dietNutrition,
        thumbnailUrl: '',
        tags: ['케토제닉', '식단관리', '레시피'],
        createdAt: now.subtract(const Duration(days: 7)),
        viewCount: 756,
        likeCount: 54,
        bookmarkCount: 98,
        isFeatured: false,
      ),
      ColumnPost(
        id: '4',
        authorId: 'expert004',
        authorName: '정우진',
        authorType: ExpertType.pediatrician,
        authorTitle: '삼성서울병원 소아청소년과 전문의',
        title: '학교생활, 이렇게 준비하세요',
        summary: '뇌전증 아동의 학교 적응을 위해 부모와 교사가 알아야 할 실질적인 조언을 제공합니다.',
        content: '''
# 학교생활 준비하기

뇌전증이 있어도 일반 학교에서 충분히 생활할 수 있습니다.

## 담임선생님과의 소통

아이의 상태를 정확히 전달하고 협조를 구하세요.

## 또래 친구들에게 알리기

나이에 맞게 설명하고 이해를 구하는 것이 좋습니다.
        ''',
        category: ColumnCategory.childcare,
        thumbnailUrl: '',
        tags: ['학교생활', '사회적응', '교육'],
        createdAt: now.subtract(const Duration(days: 10)),
        viewCount: 634,
        likeCount: 45,
        bookmarkCount: 72,
        isFeatured: false,
      ),
      ColumnPost(
        id: '5',
        authorId: 'expert005',
        authorName: '최지연',
        authorType: ExpertType.pediatricNeurologist,
        authorTitle: '고려대병원 소아신경과 교수',
        title: '2024년 뇌전증 치료의 새로운 희망',
        summary: '최신 연구 결과와 새로운 치료법 개발 현황을 소개합니다.',
        content: '''
# 2024년 뇌전증 치료의 새로운 희망

최근 뇌전증 치료 분야에서 많은 발전이 이루어지고 있습니다.

## 새로운 약물 개발

부작용이 적고 효과가 우수한 신약들이 임상시험 중입니다.

## 정밀 의료의 시대

유전자 분석을 통한 맞춤형 치료가 현실화되고 있습니다.
        ''',
        category: ColumnCategory.research,
        thumbnailUrl: '',
        tags: ['최신연구', '신약', '치료법'],
        createdAt: now.subtract(const Duration(days: 3)),
        viewCount: 523,
        likeCount: 38,
        bookmarkCount: 61,
        isFeatured: false,
      ),
      ColumnPost(
        id: '6',
        authorId: 'expert006',
        authorName: '강민수',
        authorType: ExpertType.psychologist,
        authorTitle: '연세대 심리학과 교수',
        title: '스트레스 관리와 발작 예방의 관계',
        summary: '스트레스가 발작에 미치는 영향과 효과적인 스트레스 관리 방법을 알아봅니다.',
        content: '''
# 스트레스 관리와 발작 예방

스트레스는 발작의 주요 유발 요인 중 하나입니다.

## 스트레스와 뇌전증

스트레스 호르몬이 뇌의 전기적 활동에 영향을 미칩니다.

## 효과적인 관리법

규칙적인 수면, 명상, 가벼운 운동이 도움이 됩니다.
        ''',
        category: ColumnCategory.lifestyle,
        thumbnailUrl: '',
        tags: ['스트레스', '생활관리', '예방'],
        createdAt: now.subtract(const Duration(days: 12)),
        viewCount: 478,
        likeCount: 32,
        bookmarkCount: 54,
        isFeatured: false,
      ),
      ColumnPost(
        id: '7',
        authorId: 'expert007',
        authorName: '윤서아',
        authorType: ExpertType.pediatricNeurologist,
        authorTitle: '가톨릭대병원 소아신경과 교수',
        title: '우리 아이, 발작 없는 5년의 기록',
        summary: '적극적인 치료와 관리로 발작 없는 일상을 되찾은 한 가족의 희망찬 이야기입니다.',
        content: '''
# 우리 아이, 발작 없는 5년의 기록

포기하지 않고 꾸준히 치료받은 결과, 이제는 발작 없이 생활하고 있습니다.

## 초기 진단

7세에 처음 진단받았을 때의 충격과 두려움.

## 치료 여정

다양한 약물 조정과 생활 습관 개선의 과정.

## 현재의 삶

이제는 일반 아이들과 똑같이 학교생활을 하고 있습니다.
        ''',
        category: ColumnCategory.success,
        thumbnailUrl: '',
        tags: ['치료사례', '희망', '성공스토리'],
        createdAt: now.subtract(const Duration(days: 1)),
        viewCount: 2134,
        likeCount: 187,
        bookmarkCount: 289,
        isFeatured: true,
      ),
    ];
  }

  /// 카테고리별 필터링된 목록
  List<ColumnPost> get _filteredPosts {
    if (_selectedCategory == null) {
      return _columnPosts;
    }
    return _columnPosts
        .where((post) => post.category == _selectedCategory)
        .toList();
  }

  /// 추천 칼럼 목록
  List<ColumnPost> get _featuredPosts {
    return _columnPosts.where((post) => post.isFeatured).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '건강 칼럼',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadColumnPosts,
              color: AppColors.primary,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 칼럼 섹션
                    if (_featuredPosts.isNotEmpty &&
                        _selectedCategory == null) ...[
                      _buildFeaturedSection(),
                      const SizedBox(height: 16),
                    ],

                    // 카테고리 필터
                    _buildCategoryFilter(),

                    const SizedBox(height: 16),

                    // 칼럼 목록
                    if (_filteredPosts.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredPosts.map((post) => _buildColumnCard(post)),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  /// 추천 칼럼 섹션
  Widget _buildFeaturedSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha:0.1),
            AppColors.primary.withValues(alpha:0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '추천 칼럼',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _featuredPosts.length,
              itemBuilder: (context, index) {
                return _buildFeaturedCard(_featuredPosts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 추천 칼럼 카드 (가로 스크롤)
  Widget _buildFeaturedCard(ColumnPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ColumnDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역 (플레이스홀더)
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FormatUtils.getColumnCategoryColor(post.category),
                    FormatUtils.getColumnCategoryColor(post.category).withValues(alpha:0.7),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.article,
                      size: 48,
                      color: Colors.white.withValues(alpha:0.8),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '추천',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.authorName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.visibility_outlined,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${post.viewCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 필터
  Widget _buildCategoryFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppStyles.cardShadow,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CategoryChip(
              label: '전체',
              isSelected: _selectedCategory == null,
              count: _columnPosts.length,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 8),
            ...ColumnCategory.values.map((category) {
              final count = _columnPosts
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
    );
  }

  /// 칼럼 카드
  Widget _buildColumnCard(ColumnPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ColumnDetailScreen(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역 (플레이스홀더)
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FormatUtils.getColumnCategoryColor(post.category),
                    FormatUtils.getColumnCategoryColor(post.category).withValues(alpha:0.7),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.article_outlined,
                      size: 60,
                      color: Colors.white.withValues(alpha:0.7),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.category.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: FormatUtils.getColumnCategoryColor(post.category),
                        ),
                      ),
                    ),
                  ),
                  if (post.isFeatured)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 요약
                  Text(
                    post.summary,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 작성자 정보
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha:0.1),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              post.authorType.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 읽는 시간
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${FormatUtils.estimateReadingTime(post.content)}분',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 하단 정보
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.viewCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_border,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.bookmark_border,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.bookmarkCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        FormatUtils.getTimeAgoText(post.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  /// 빈 상태 화면
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '칼럼이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
