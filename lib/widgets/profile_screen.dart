import 'package:flutter/material.dart';
import 'medical_report_period_screen.dart';
import 'seizure_alert_screen.dart';
import 'smartwatch_monitor_screen.dart';
import '../utils/backend_service.dart';

/// 개인정보 화면 (Placeholder)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '개인정보',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 프로필 섹션
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // 사용자 정보
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자 이름',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 건강 관리
          _buildSection('건강 관리', [
            _buildMenuItem(
              icon: Icons.warning_amber_rounded,
              title: '발작 예측 확인',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder(
                      future: BackendService.fetchSeizurePrediction(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SeizureAlertScreen(
                            predictionData: snapshot.data!,
                            onSeizureConfirmed: () async {
                              await BackendService.confirmSeizureOccurred(
                                timestamp: DateTime.now(),
                                predictionRate: snapshot.data!.predictionRate,
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('오류')),
                            body: Center(
                              child: Text('데이터 로드 실패: ${snapshot.error}'),
                            ),
                          );
                        } else {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.watch,
              title: '스마트워치 모니터링',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SmartwatchMonitorScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.medical_information,
              title: '의료 보고서 생성',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MedicalReportPeriodScreen(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),

          // 계정 설정
          _buildSection('계정 설정', [
            _buildMenuItem(
              icon: Icons.person_outline,
              title: '프로필 수정',
              onTap: () {
                debugPrint('프로필 수정 클릭');
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: '비밀번호 변경',
              onTap: () {
                debugPrint('비밀번호 변경 클릭');
              },
            ),
          ]),

          const SizedBox(height: 16),

          // 앱 설정
          _buildSection('앱 설정', [
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: '알림 설정',
              onTap: () {
                debugPrint('알림 설정 클릭');
              },
            ),
            _buildMenuItem(
              icon: Icons.language,
              title: '언어 설정',
              onTap: () {
                debugPrint('언어 설정 클릭');
              },
            ),
          ]),

          const SizedBox(height: 16),

          // 약관 및 정책
          _buildSection('약관 및 정책', [
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () {
                debugPrint('이용약관 클릭');
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              onTap: () {
                debugPrint('개인정보 처리방침 클릭');
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: '앱 정보',
              onTap: () {
                _showAppInfo(context);
              },
            ),
          ]),

          const SizedBox(height: 16),

          // 로그아웃
          Container(
            color: Colors.white,
            child: _buildMenuItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () {
                _showLogoutDialog(context);
              },
              isDestructive: true,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  /// 메뉴 아이템
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red : Colors.black54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// 앱 정보 다이얼로그
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seizure시계'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('뇌전증 환자를 위한 헬스케어 앱'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 로그아웃 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 로그아웃 처리
              debugPrint('로그아웃 처리');
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
