import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/qna_post.dart';
import '../models/column_post.dart';
import '../models/community_post.dart';

/// 포맷팅 유틸리티 함수
class FormatUtils {
  FormatUtils._(); // 인스턴스화 방지

  /// 시간 경과 표시용 텍스트 생성 (예: "3시간 전", "2일 전")
  static String getTimeAgoText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }

  /// 칼럼 읽는 시간 예상 (분)
  static int estimateReadingTime(String content) {
    // 평균 분당 200자 읽기 가정
    final charCount = content.length;
    final minutes = (charCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// 숫자를 K/M 단위로 축약 (예: 1,234 -> 1.2K)
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// Q&A 카테고리별 색상 반환
  static Color getQnaCategoryColor(QnaCategory category) {
    switch (category) {
      case QnaCategory.medication:
        return AppColors.categoryMedication;
      case QnaCategory.seizure:
        return AppColors.categorySeizure;
      case QnaCategory.diet:
        return AppColors.categoryDiet;
      case QnaCategory.lifestyle:
        return AppColors.categoryLifestyle;
      case QnaCategory.medical:
        return AppColors.categoryMedical;
      case QnaCategory.other:
        return AppColors.categoryOther;
    }
  }

  /// 칼럼 카테고리별 색상 반환
  static Color getColumnCategoryColor(ColumnCategory category) {
    switch (category) {
      case ColumnCategory.seizureInfo:
        return AppColors.columnSeizureInfo;
      case ColumnCategory.medicationGuide:
        return AppColors.columnMedicationGuide;
      case ColumnCategory.dietNutrition:
        return AppColors.columnDietNutrition;
      case ColumnCategory.childcare:
        return AppColors.columnChildcare;
      case ColumnCategory.research:
        return AppColors.columnResearch;
      case ColumnCategory.lifestyle:
        return AppColors.columnLifestyle;
      case ColumnCategory.success:
        return AppColors.columnSuccess;
    }
  }

  /// 커뮤니티 카테고리별 색상 반환
  static Color getCommunityCategoryColor(CommunityCategory category) {
    switch (category) {
      case CommunityCategory.korean:
        return const Color(0xFFE53935); // 빨강
      case CommunityCategory.chinese:
        return const Color(0xFFFB8C00); // 주황
      case CommunityCategory.western:
        return const Color(0xFF43A047); // 초록
      case CommunityCategory.japanese:
        return const Color(0xFF1E88E5); // 파랑
      case CommunityCategory.other:
        return const Color(0xFF757575); // 회색
    }
  }
}
