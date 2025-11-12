import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../models/diet_entry.dart';
import '../models/nutrition_info.dart';
import '../constants/app_colors.dart';
import '../utils/format_utils.dart';
import '../services/diet_service.dart';
import 'meal_time_selection_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityPost post;
  final MealTime? selectedMealTime;
  final DateTime? selectedDate;

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
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Community Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Copy to my diet',
            onPressed: _copyToMyDiet,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            _buildHeader(post),
            _buildSummarySection(post),
            _buildNutritionSection(post.nutrition),
            _buildIngredientsSection(),
            _buildCookingStepsSection(),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 220,
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
          size: 72,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildHeader(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  post.userName.isNotEmpty
                      ? post.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    FormatUtils.getTimeAgoText(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey[600],
                ),
              ),
              Text('$_likeCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.content, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(NutritionInfo? info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Facts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: info == null
                ? _buildEmptyInfoCard('No nutrition data provided.')
                : Column(
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
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final entries = widget.post.ingredients.entries.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _buildEmptyInfoCard('No ingredients were provided for this post.')
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  final isLast = index == entries.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            ingredient.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            ingredient.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCookingStepsSection() {
    final steps = widget.post.cookingSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cooking Steps',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (steps.isEmpty)
            _buildEmptyInfoCard('No cooking steps were provided.')
          else
            Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
    final denominator = info.protein + info.carbs;
    if (info.fat <= 0 || denominator <= 0) return '-';
    final ratio = info.fat / denominator;
    return '${ratio.toStringAsFixed(2)}:1';
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comments',
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
          const SizedBox(height: 12),
          if (_comments.isEmpty)
            _buildEmptyInfoCard(
              'Be the first to share feedback about this recipe.',
            )
          else
            ..._comments.map(_buildCommentItem),
        ],
      ),
    );
  }

  Widget _buildCommentItem(_Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  comment.userName.isNotEmpty
                      ? comment.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

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
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
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
            IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyInfoCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount = (_likeCount - 1).clamp(0, 1 << 30);
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        _Comment(userName: 'Me', content: text, createdAt: DateTime.now()),
      );
      _commentController.clear();
    });
  }

  Future<void> _copyToMyDiet() async {
    MealTimeType? selectedMeal;
    if (widget.selectedMealTime != null) {
      selectedMeal = _convertMealTime(widget.selectedMealTime!);
    } else {
      selectedMeal = await showDialog<MealTimeType>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select meal time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: MealTimeType.values
                .map(
                  (mealTime) => ListTile(
                    title: Text(mealTime.displayName),
                    onTap: () => Navigator.of(context).pop(mealTime),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (selectedMeal == null || !mounted) return;

    final targetDate = widget.selectedDate ?? DateTime.now();
    await DietService().addDietEntry(
      date: targetDate,
      mealTime: selectedMeal,
      recipe: widget.post,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedMeal.displayName} entry created.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
}

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
