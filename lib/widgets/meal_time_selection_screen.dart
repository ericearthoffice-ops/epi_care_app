import 'package:flutter/material.dart';
import 'meal_category_selection_screen.dart';

/// 식사 시간 선택 화면
/// 아침, 점심, 저녁 중 선택
class MealTimeSelectionScreen extends StatelessWidget {
  final DateTime selectedDate;

  const MealTimeSelectionScreen({
    super.key,
    required this.selectedDate,
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
              '어느 시간대의 식단을 찾고있나요?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 60),

            // 시간대 선택 카드들
            _buildMealTimeCard(
              context: context,
              mealTime: MealTime.breakfast,
              label: '아침',
              icon: Icons.wb_sunny_outlined,
              color: const Color(0xFFFFB74D), // 주황색
            ),

            const SizedBox(height: 20),

            _buildMealTimeCard(
              context: context,
              mealTime: MealTime.lunch,
              label: '점심',
              icon: Icons.wb_sunny,
              color: const Color(0xFFFDD835), // 노란색
            ),

            const SizedBox(height: 20),

            _buildMealTimeCard(
              context: context,
              mealTime: MealTime.dinner,
              label: '저녁',
              icon: Icons.nightlight_round,
              color: const Color(0xFF5C6BC0), // 보라색
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 식사 시간 선택 카드
  Widget _buildMealTimeCard({
    required BuildContext context,
    required MealTime mealTime,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // 음식 카테고리 선택 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MealCategorySelectionScreen(
              selectedDate: selectedDate,
              mealTime: mealTime,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
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
        child: Row(
          children: [
            const SizedBox(width: 40),

            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 45,
                color: color,
              ),
            ),

            const SizedBox(width: 30),

            // 텍스트
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
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

/// 식사 시간 enum
enum MealTime {
  breakfast('아침'),
  lunch('점심'),
  dinner('저녁');

  final String displayName;
  const MealTime(this.displayName);
}
