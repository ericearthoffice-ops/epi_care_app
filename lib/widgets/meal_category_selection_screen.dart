import 'package:flutter/material.dart';
import '../models/community_post.dart';
import 'meal_time_selection_screen.dart';
import 'community_list_screen.dart';

/// 음식 카테고리 선택 화면
/// 한식, 중식, 양식, 일식 중 선택
class MealCategorySelectionScreen extends StatelessWidget {
  final DateTime selectedDate;
  final MealTime mealTime;

  const MealCategorySelectionScreen({
    super.key,
    required this.selectedDate,
    required this.mealTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 제목
            const Text(
              '오늘의 식단',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // 부제
            Text(
              '어떤 음식을 찾고 계신가요?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 60),

            // 음식 카테고리 그리드
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildCategoryCard(
                  context: context,
                  category: CommunityCategory.korean,
                  label: '한식',
                  imagePath: 'assets/images/Korean.png',
                  color: const Color(0xFFE53935),
                ),
                _buildCategoryCard(
                  context: context,
                  category: CommunityCategory.chinese,
                  label: '중식',
                  imagePath: 'assets/images/Chinese.png',
                  color: const Color(0xFFFB8C00),
                ),
                _buildCategoryCard(
                  context: context,
                  category: CommunityCategory.western,
                  label: '양식',
                  imagePath: 'assets/images/Western.png',
                  color: const Color(0xFF43A047),
                ),
                _buildCategoryCard(
                  context: context,
                  category: CommunityCategory.japanese,
                  label: '일식',
                  imagePath: 'assets/images/Japanese.png',
                  color: const Color(0xFF1E88E5),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 음식 카테고리 카드
  Widget _buildCategoryCard({
    required BuildContext context,
    required CommunityCategory category,
    required String label,
    required String imagePath,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // 선택한 카테고리로 커뮤니티 화면으로 이동 (인기순 정렬)
        // 시간대 정보도 함께 전달
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommunityListScreen(
              initialCategory: category,
              initialSortOrder: SortOrder.popular,
              selectedMealTime: mealTime,
              selectedDate: selectedDate,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 텍스트
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
