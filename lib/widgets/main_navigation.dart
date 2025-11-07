import 'package:flutter/material.dart';

import 'diet_calendar_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'seizure_record_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DietCalendarScreen(),
    SeizureRecordScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              children:
                  [
                        _NavItemData(
                          assetPath: 'assets/images/Home icon.png',
                          label: '홈',
                        ),
                        _NavItemData(
                          assetPath: 'assets/images/Calender icon.png',
                          label: '식이/복용',
                        ),
                        _NavItemData(
                          assetPath: 'assets/images/Record icon.png',
                          label: '발작 기록',
                        ),
                        _NavItemData(
                          assetPath: 'assets/images/User icon.png',
                          label: '개인정보',
                        ),
                      ]
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildNavItem(
                          assetPath: entry.value.assetPath,
                          label: entry.value.label,
                          index: entry.key,
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String assetPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    const double iconSize = 24;

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
            Opacity(
              opacity: isSelected ? 1 : 0.5,
              child: Image.asset(assetPath, width: iconSize, height: iconSize),
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

class _NavItemData {
  final String assetPath;
  final String label;

  const _NavItemData({required this.assetPath, required this.label});
}
