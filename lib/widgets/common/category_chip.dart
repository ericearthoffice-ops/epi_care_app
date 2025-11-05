import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

/// 카테고리 선택 칩 위젯
/// Q&A 및 칼럼 목록에서 재사용
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingMedium,
          vertical: AppStyles.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: AppStyles.borderRadiusXLarge,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppStyles.captionSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.grey700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
