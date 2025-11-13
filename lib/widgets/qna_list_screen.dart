import 'package:flutter/material.dart';
import '../models/qna_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/qna_service.dart';
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

  /// Q&A 목록 로드
  Future<void> _loadQnaPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await QnaService.fetchPosts();
      if (!mounted) return;
      setState(() {
        _qnaPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _qnaPosts = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Q&A 데이터를 불러오지 못했어요. 잠시 후 다시 시도해주세요.\n($e)'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  List<QnaPost> get _filteredPosts {
    if (_selectedCategory == null) {
      return _qnaPosts;
    }
    return _qnaPosts
        .where((post) => post.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Q&A',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 질문 등록하기 버튼
          IconButton(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/images/Column.png',
                fit: BoxFit.contain,
              ),
            ),
            tooltip: '질문 등록하기',
            onPressed: () async {
              final shouldRefresh = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (context) => const QnaWriteScreen()),
              );
              if (shouldRefresh == true) {
                _loadQnaPosts();
              }
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
                    child: CircularProgressIndicator(color: AppColors.primary),
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
              final count = _qnaPosts
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: FormatUtils.getQnaCategoryColor(
                        post.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FormatUtils.getQnaCategoryColor(
                          post.category,
                        ).withValues(alpha: 0.3),
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
                    Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                  const Spacer(),
                  // 채택 완료 뱃지
                  if (post.hasAcceptedAnswer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
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
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    post.expertType.displayName,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  // 작성 시간
                  Text(
                    FormatUtils.getTimeAgoText(post.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const QnaWriteScreen(),
                    ),
                  )
                  .then((_) {
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
