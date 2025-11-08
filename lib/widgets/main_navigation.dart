import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'diet_calendar_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'seizure_record_screen.dart';
import 'seizure_alert_screen.dart';
import '../utils/backend_service.dart';

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
  void initState() {
    super.initState();
    _checkNotificationLaunch();
  }

  /// 앱이 알림으로 실행되었는지 체크하고, 그렇다면 SeizureAlertScreen으로 이동
  Future<void> _checkNotificationLaunch() async {
    debugPrint('📱 Checking if app was launched from notification...');
    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    final details = await notifications.getNotificationAppLaunchDetails();
    debugPrint('📱 didNotificationLaunchApp: ${details?.didNotificationLaunchApp}');
    debugPrint('📱 payload: ${details?.notificationResponse?.payload}');

    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details?.notificationResponse?.payload;
      debugPrint('🔔 App was launched from notification with payload: $payload');

      if (payload == 'seizure_prediction' && mounted) {
        debugPrint('🚀 Scheduling navigation to SeizureAlertScreen...');
        // 앱이 알림으로 실행되었고, payload가 'seizure_prediction'이면
        // SeizureAlertScreen으로 이동
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            debugPrint('✅ Navigating to SeizureAlertScreen');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FutureBuilder(
                  future: BackendService.fetchSeizurePrediction(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      debugPrint('✅ Data loaded, showing SeizureAlertScreen');
                      return SeizureAlertScreen(
                        predictionData: snapshot.data!,
                        onSeizureConfirmed: () async {
                          await BackendService.confirmSeizureOccurred(
                            timestamp: DateTime.now(),
                            predictionRate: snapshot.data!.predictionRate,
                          );
                        },
                      );
                    } else {
                      debugPrint('⏳ Loading prediction data...');
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            );
          } else {
            debugPrint('❌ Widget is not mounted');
          }
        });
      }
    } else {
      debugPrint('ℹ️ App was not launched from notification');
    }
  }

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
