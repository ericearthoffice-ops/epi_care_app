import 'package:flutter/material.dart';
import '../models/qna_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/format_utils.dart';
import '../widgets/common/category_chip.dart';
import 'qna_write_screen.dart';

/// Q&A 목록 화면
/// 다른 사용자들이 작성한 질문 목록을 카테고리별로 확인할 수 있는 화면
class QnaListScreen extends StatefulWidget {
  const QnaListScreen({super.key});

  @override
  State<QnaListScreen> createState() => _QnaListScreenState();
}

class _QnaListScreenState extends State<QnaListScreen> {
  QnaCategory? _selectedCategory; // null이면 전체 보기
  List<QnaPost> _qnaPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQnaPosts();
  }

  /// Q&A 목록 로드 (Mock 데이터)
  Future<void> _loadQnaPosts() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: 백엔드 API 연동
    // 현재는 Mock 데이터
    await Future.delayed(const Duration(seconds: 1));

    final mockPosts = _generateMockPosts();

    setState(() {
      _qnaPosts = mockPosts;
      _isLoading = false;
    });
  }

  /// Mock 데이터 생성
  List<QnaPost> _generateMockPosts() {
    final now = DateTime.now();
    return [
      QnaPost(
        id: '1',
        userId: 'user001',
        userName: '김민지',
        title: '레베티라세탐을 늦게 먹으면 어떻게 해야 하나요?',
        content:
            '오늘 아침 8시에 먹어야 하는데 깜빡하고 오후 2시에 생각났습니다. 바로 먹어야 할까요?',
        category: QnaCategory.medication,
        expertType: ExpertType.pharmacist,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 3)),
        viewCount: 24,
        answerCount: 2,
        hasAcceptedAnswer: true,
      ),
      QnaPost(
        id: '2',
        userId: 'user002',
        userName: '이서준',
        title: '발작이 일어났을 때 응급처치 방법이 궁금합니다',
        content: '학교에서 발작이 일어나면 어떻게 대처해야 하나요? 선생님께 알려드려야 할 내용이 있을까요?',
        category: QnaCategory.seizure,
        expertType: ExpertType.pediatricNeurologist,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 5)),
        viewCount: 45,
        answerCount: 3,
        hasAcceptedAnswer: true,
      ),
      QnaPost(
        id: '3',
        userId: 'user003',
        userName: '박지우',
        title: '케토제닉 식단에서 먹을 수 있는 간식이 있나요?',
        content: '아이가 간식을 먹고 싶어 하는데, 케토제닉 식단을 유지하면서 먹을 수 있는 것이 있을까요?',
        category: QnaCategory.diet,
        expertType: ExpertType.dietitian,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 8)),
        viewCount: 18,
        answerCount: 1,
        hasAcceptedAnswer: false,
      ),
      QnaPost(
        id: '4',
        userId: 'user004',
        userName: '최서연',
        title: '약 부작용 관련 질문입니다',
        content: '최근 약을 바꿨는데 졸림이 심합니다. 이런 증상이 정상인가요?',
        category: QnaCategory.medication,
        expertType: ExpertType.pediatricNeurologist,
        isPrivate: true, // 비공개 질문
        createdAt: now.subtract(const Duration(days: 1)),
        viewCount: 5,
        answerCount: 1,
        hasAcceptedAnswer: false,
      ),
      QnaPost(
        id: '5',
        userId: 'user005',
        userName: '정다은',
        title: '체육 수업 참여해도 괜찮을까요?',
        content: '학교 체육 수업에 참여해도 되는지 궁금합니다. 주의해야 할 운동이 있나요?',
        category: QnaCategory.lifestyle,
        expertType: ExpertType.pediatrician,
        isPrivate: false,
        createdAt: now.subtract(const Duration(days: 2)),
        viewCount: 32,
        answerCount: 2,
        hasAcceptedAnswer: true,
      ),
      QnaPost(
        id: '6',
        userId: 'user006',
        userName: '강민호',
        title: 'EEG 검사 결과 해석 부탁드립니다',
        content: '최근 EEG 검사를 받았는데 결과지 내용이 이해가 잘 안됩니다.',
        category: QnaCategory.medical,
        expertType: ExpertType.pediatricNeurologist,
        isPrivate: true, // 비공개 질문
        createdAt: now.subtract(const Duration(days: 3)),
        viewCount: 8,
        answerCount: 1,
        hasAcceptedAnswer: true,
      ),
      QnaPost(
        id: '7',
        userId: 'user007',
        userName: '윤수빈',
        title: '약을 까먹고 안 먹으면 어떻게 되나요?',
        content: '가끔 약 먹는 것을 까먹는데, 한두 번 정도는 괜찮을까요?',
        category: QnaCategory.medication,
        expertType: ExpertType.pharmacist,
        isPrivate: false,
        createdAt: now.subtract(const Duration(days: 5)),
        viewCount: 67,
        answerCount: 4,
        hasAcceptedAnswer: true,
      ),
    ];
  }

  /// 카테고리별 필터링된 목록
  List<QnaPost> get _filteredPosts {
    if (_selectedCategory == null) {
      return _qnaPosts;
    }
    return _qnaPosts.where((post) => post.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Q&A',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 질문 등록하기 버튼
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: '질문 등록하기',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QnaWriteScreen(),
                ),
              ).then((_) {
                // 질문 작성 후 돌아왔을 때 목록 새로고침
                _loadQnaPosts();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터 탭
          _buildCategoryFilter(),

          // 질문 목록
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _filteredPosts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadQnaPosts,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            return _buildQnaCard(_filteredPosts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터 탭
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
              count: _qnaPosts.length,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 8),
            ...QnaCategory.values.map((category) {
              final count =
                  _qnaPosts.where((post) => post.category == category).length;
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

  /// Q&A 카드
  Widget _buildQnaCard(QnaPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          // TODO: 질문 상세 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('질문 상세 화면 (ID: ${post.id})'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 카테고리 + 비공개 아이콘 + 채택 여부
              Row(
                children: [
                  // 카테고리 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FormatUtils.getQnaCategoryColor(post.category).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FormatUtils.getQnaCategoryColor(post.category).withValues(alpha:0.3),
                      ),
                    ),
                    child: Text(
                      post.category.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FormatUtils.getQnaCategoryColor(post.category),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 비공개 아이콘
                  if (post.isPrivate)
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  const Spacer(),
                  // 채택 완료 뱃지
                  if (post.hasAcceptedAnswer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '채택완료',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 질문 제목
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 질문 내용 미리보기
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 하단: 전문가 분야 + 답변 수 + 조회수 + 시간
              Row(
                children: [
                  // 전문가 분야
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.expertType.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 답변 수
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: post.answerCount > 0
                        ? AppColors.primary
                        : Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.answerCount}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: post.answerCount > 0
                          ? AppColors.primary
                          : Colors.grey[600],
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
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // 작성 시간
                  Text(
                    FormatUtils.getTimeAgoText(post.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            Icons.question_answer_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '아직 질문이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 질문을 등록해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QnaWriteScreen(),
                ),
              ).then((_) {
                _loadQnaPosts();
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('질문 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
