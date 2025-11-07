import 'package:flutter/material.dart';

/// 로딩 화면 위젯
/// 백엔드 응답이 지연될 때 표시됩니다
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로딩 화면 이미지
            Image.asset(
              'assets/images/Loading_screen.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // "로딩중..." 텍스트
            const Text(
              '로딩중...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5B7FFF), // 파란색
              ),
            ),

            const SizedBox(height: 16),

            // 로딩 인디케이터
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
