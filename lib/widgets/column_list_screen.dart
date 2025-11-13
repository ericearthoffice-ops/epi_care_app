import 'package:flutter/material.dart';
import '../models/column_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/column_service.dart';
import '../utils/format_utils.dart';
import '../widgets/common/category_chip.dart';
import 'column_detail_screen.dart';

/// Expert column list screen backed by the local ColumnService.
class ColumnListScreen extends StatefulWidget {
  const ColumnListScreen({super.key});

  @override
  State<ColumnListScreen> createState() => _ColumnListScreenState();
}

class _ColumnListScreenState extends State<ColumnListScreen> {
  ColumnCategory? _selectedCategory;
  List<ColumnPost> _columnPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColumnPosts();
  }

  Future<void> _loadColumnPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await ColumnService.fetchPosts(category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _columnPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _columnPosts = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('칼럼을 불러오지 못했어요. 잠시 후 다시 시도해주세요.\n($e)'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  List<ColumnPost> get _filteredPosts {
    if (_selectedCategory == null) {
      return _columnPosts;
    }
    return _columnPosts
        .where((post) => post.category == _selectedCategory)
        .toList();
  }

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadColumnPosts,
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 24,
                ),
                children: [
                  if (_featuredPosts.isNotEmpty &&
                      _selectedCategory == null) ...[
                    _buildFeaturedSection(),
                    const SizedBox(height: 20),
                  ],
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  if (_filteredPosts.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredPosts.map(_buildColumnCard),
                ],
              ),
            ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '추천 칼럼',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.star_rounded, color: AppColors.warning),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredPosts.length,
            itemBuilder: (context, index) {
              final post = _featuredPosts[index];
              final isLast = index == _featuredPosts.length - 1;
              return Container(
                margin: EdgeInsets.only(right: isLast ? 0 : 12),
                child: _buildFeaturedCard(post),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(ColumnPost post) {
    final gradient = LinearGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.85),
        AppColors.primaryDark,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: 260,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ColumnDetailScreen(post: post)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient,
            boxShadow: AppStyles.cardShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.category.displayName,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                post.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(
            label: '전체',
            isSelected: _selectedCategory == null,
            count: _columnPosts.length,
            onTap: () {
              setState(() {
                _selectedCategory = null;
              });
              _loadColumnPosts();
            },
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
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _loadColumnPosts();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColumnCard(ColumnPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppStyles.cardShadow,
      ),
      child: InkWell(
        borderRadius: AppStyles.borderRadiusMedium,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ColumnDetailScreen(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: FormatUtils.getColumnCategoryColor(
                        post.category,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FormatUtils.getColumnCategoryColor(
                          post.category,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.bookmark,
                    size: 18,
                    color: post.isFeatured
                        ? AppColors.warning
                        : Colors.transparent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${FormatUtils.estimateReadingTime(post.content)}m read',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
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
                  const SizedBox(width: 12),
                  Icon(
                    Icons.favorite_border,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.bookmark_border,
                    size: 14,
                    color: Colors.grey[500],
                  ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '아직 칼럼이 없습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 칼럼이 등록되면 이곳에서 확인할 수 있어요.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
