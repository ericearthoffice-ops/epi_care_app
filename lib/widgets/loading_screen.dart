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
            // 고양이 캐릭터 이미지
            // TODO: assets/images/loading_cat.png 파일이 추가되면 주석 해제
            // Image.asset(
            //   'assets/images/loading_cat.png',
            //   width: 200,
            //   height: 200,
            // ),

            // 임시 placeholder (이미지 추가 전까지 사용)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.pets,
                size: 100,
                color: Colors.grey[400],
              ),
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
