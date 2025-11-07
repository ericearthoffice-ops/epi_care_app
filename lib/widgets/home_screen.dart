import 'package:flutter/material.dart';
import '../utils/notification_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'qna_list_screen.dart';
import 'column_list_screen.dart';
import 'community_list_screen.dart';
import 'medical_report_period_screen.dart';

/// 홈화면 - 앱 최초 진입 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더
              _buildHeader(),

              const SizedBox(height: 24),

              // Q&A, 커뮤니티, 칼럼 버튼
              _buildTopButtons(context),

              const SizedBox(height: 24),

              // 의료 보고서 생성 버튼
              _buildMedicalReportButton(context),

              const SizedBox(height: 32),

              // 인기질문 섹션
              _buildPopularQuestions(),

              const SizedBox(height: 80), // 하단 네비게이션 바 공간
            ],
          ),
        ),
      ),
      // TODO: 테스트용 버튼 - 실제 운영 시 제거 필요
      // 발작 예측 알림을 테스트하기 위한 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 테스트용: 발작 예측 알림 표시 (70% 확률)
          await NotificationService.showSeizurePredictionNotification(
            predictionRate: 70.0,
            isOngoing: true, // 알림창에 계속 떠있음
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  '알림이 표시되었습니다!\n\n'
                  '📱 화면 상단을 아래로 스와이프하여\n'
                  '알림창을 열고 "Seizure 시져" 알림을 클릭하세요.',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: '확인',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.notification_add),
        label: const Text('테스트 알림'),
      ),
    );
  }

  /// 상단 헤더 (Seizure시계 + 아이콘)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Seizure 시져',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          // 아이콘 (임시 - 실제 아이콘 이미지로 교체 가능)
          _HeaderIcon(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Q&A, 커뮤니티, 칼럼 버튼
  Widget _buildTopButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            imagePath: 'assets/images/QA.png',
            label: 'Q&A',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QnaListScreen(),
                ),
              );
            },
          ),
          _buildIconButton(
            imagePath: 'assets/images/Community.png',
            label: '커뮤니티',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CommunityListScreen(),
                ),
              );
            },
          ),
          _buildIconButton(
            imagePath: 'assets/images/Column.png',
            label: '칼럼',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ColumnListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 아이콘 버튼
  Widget _buildIconButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.grey300),
              boxShadow: AppStyles.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 의료 보고서 생성 버튼
  Widget _buildMedicalReportButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingMedium),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MedicalReportPeriodScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5B7FFF),
                Color(0xFF4A6AE8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B7FFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_information,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '의료 보고서 생성',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '발작·식이·약 기록을 PDF로 내보내기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 인기질문 섹션
  Widget _buildPopularQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingMedium),
          child: Text(
            '인기질문',
            style: AppStyles.h3,
          ),
        ),
        const SizedBox(height: 16),
        const _QuestionItem(
          number: 1,
          question: '약을 까먹고 안 먹으면 어떻게 되나요?',
          answerCount: 3,
        ),
        const _QuestionItem(
          number: 2,
          question: '조사 보관함의 과거 이상이 있다고 하는 다른 곳들은 전부으로 먼씹니까?',
          answerCount: 1,
        ),
        // 추가 질문들...
      ],
    );
  }
}

/// 헤더 아이콘 위젯 (const 최적화)
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/Neuron.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// 질문 아이템 위젯 (const 최적화)
class _QuestionItem extends StatelessWidget {
  final int number;
  final String question;
  final int answerCount;

  const _QuestionItem({
    required this.number,
    required this.question,
    required this.answerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingMedium,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey300),
        borderRadius: AppStyles.borderRadiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 번호
          Text(
            '$number',
            style: AppStyles.bodyMedium.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          // 질문 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // 답변 수
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$answerCount',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
