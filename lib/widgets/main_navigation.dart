import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'diet_calendar_screen.dart';
import 'seizure_record_screen.dart';
import 'profile_screen.dart';

/// 메인 네비게이션 화면
/// 하단 네비게이션 바를 포함하여 4개의 메인 화면을 관리
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 네비게이션 화면 목록
  final List<Widget> _screens = [
    const HomeScreen(),
    const DietCalendarScreen(),
    const SeizureRecordScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: '홈',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  label: '식이/복용',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.list_alt,
                  label: '발작 기록',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: '개인정보',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템 빌더
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF5B7FFF) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF5B7FFF) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
