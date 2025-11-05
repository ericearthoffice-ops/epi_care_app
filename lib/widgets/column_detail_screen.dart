import 'package:flutter/material.dart';
import '../models/column_post.dart';
import '../constants/app_colors.dart';
import '../utils/format_utils.dart';

/// 칼럼 상세 화면
/// 칼럼의 전체 내용을 읽을 수 있는 화면
class ColumnDetailScreen extends StatefulWidget {
  final ColumnPost post;

  const ColumnDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<ColumnDetailScreen> createState() => _ColumnDetailScreenState();
}

class _ColumnDetailScreenState extends State<ColumnDetailScreen> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  int _bookmarkCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _bookmarkCount = widget.post.bookmarkCount;
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

  /// 북마크 토글
  void _toggleBookmark() {
    setState(() {
      if (_isBookmarked) {
        _isBookmarked = false;
        _bookmarkCount--;
      } else {
        _isBookmarked = true;
        _bookmarkCount++;
      }
    });
    // TODO: 백엔드 API 연동
  }

  /// 공유하기
  void _share() {
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('공유 기능은 곧 추가될 예정입니다.'),
        duration: Duration(seconds: 2),
      ),
    );
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
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.primary : Colors.black87,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역
            _buildHeader(),

            const SizedBox(height: 24),

            // 본문
            _buildContent(),

            const SizedBox(height: 32),

            // 태그
            if (widget.post.tags.isNotEmpty) _buildTags(),

            const SizedBox(height: 32),

            // 하단 액션 버튼
            _buildActionButtons(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 헤더 영역
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FormatUtils.getColumnCategoryColor(widget.post.category).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FormatUtils.getColumnCategoryColor(widget.post.category).withValues(alpha:0.3),
              ),
            ),
            child: Text(
              widget.post.category.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: FormatUtils.getColumnCategoryColor(widget.post.category),
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

          // 요약
          Text(
            widget.post.summary,
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
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha:0.1),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.post.authorTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 메타 정보
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                FormatUtils.getTimeAgoText(widget.post.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${FormatUtils.estimateReadingTime(widget.post.content)}분 소요',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${widget.post.viewCount}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 구분선
          Divider(color: Colors.grey[200], thickness: 1),
        ],
      ),
    );
  }

  /// 본문
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실제로는 마크다운 렌더러를 사용해야 하지만,
          // 여기서는 간단히 텍스트로 표시
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 태그
  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.post.tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 하단 액션 버튼
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 좋아요
          _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: '좋아요',
            count: _likeCount,
            isActive: _isLiked,
            onPressed: _toggleLike,
          ),

          // 북마크
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            label: '저장',
            count: _bookmarkCount,
            isActive: _isBookmarked,
            onPressed: _toggleBookmark,
          ),

          // 공유
          _buildActionButton(
            icon: Icons.share_outlined,
            label: '공유',
            count: 0,
            isActive: false,
            onPressed: _share,
            hideCount: true,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onPressed,
    bool hideCount = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppColors.primary : Colors.grey[700],
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (!hideCount && count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isActive ? AppColors.primary : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
