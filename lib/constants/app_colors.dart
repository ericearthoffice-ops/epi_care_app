import 'package:flutter/material.dart';

/// 앱 전역 색상 상수
class AppColors {
  AppColors._(); // 인스턴스화 방지

  // Primary Colors
  static const Color primary = Color(0xFF5B7FFF);
  static const Color primaryLight = Color(0xFF8BA3FF);
  static const Color primaryDark = Color(0xFF4A6FEE);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Category Colors (Q&A)
  static const Color categoryMedication = Color(0xFF4CAF50); // 초록색
  static const Color categorySeizure = Color(0xFFF44336); // 빨간색
  static const Color categoryDiet = Color(0xFFFF9800); // 주황색
  static const Color categoryLifestyle = Color(0xFF2196F3); // 파란색
  static const Color categoryMedical = Color(0xFF9C27B0); // 보라색
  static const Color categoryOther = Color(0xFF607D8B); // 회색

  // Column Category Colors
  static const Color columnSeizureInfo = Color(0xFFF44336);
  static const Color columnMedicationGuide = Color(0xFF4CAF50);
  static const Color columnDietNutrition = Color(0xFFFF9800);
  static const Color columnChildcare = Color(0xFF2196F3);
  static const Color columnResearch = Color(0xFF9C27B0);
  static const Color columnLifestyle = Color(0xFF00BCD4);
  static const Color columnSuccess = Color(0xFFFFB800);

  // Accent Colors
  static const Color accent = Color(0xFFFFB800); // 금색 (별표, 추천 등)
  static const Color like = Color(0xFFE91E63); // 좋아요
  static const Color bookmark = primary;

  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
