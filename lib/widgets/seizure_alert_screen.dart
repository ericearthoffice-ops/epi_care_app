import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/seizure_prediction_data.dart';
import '../utils/backend_service.dart';

/// 발작 예측 알림 화면
class SeizureAlertScreen extends StatelessWidget {
  final SeizurePredictionData predictionData;
  final VoidCallback? onSeizureConfirmed; // "예" 버튼 클릭 시 (백엔드 전송용)

  const SeizureAlertScreen({
    super.key,
    required this.predictionData,
    this.onSeizureConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '발작예측',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // 도움 요청 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _requestHelp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.emergency, size: 18),
              label: const Text(
                '도움 요청',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 발작 예측 확률 카드
              _buildPredictionCard(context),

              const SizedBox(height: 24),

              // 데이터 테이블
              _buildDataTable(context),

              const SizedBox(height: 32),

              // "발작이 일어났나요?" 질문
              const Text(
                '발작이 일어났나요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // 예/아니요 버튼
              Row(
                children: [
                  Expanded(
                    child: _buildResponseButton(
                      context,
                      label: '예',
                      onPressed: () async {
                        // 발작 발생 확인 - 학습 피드백 전송
                        await BackendService.submitPredictionFeedback(
                          timestamp: DateTime.now(),
                          predictionRate: predictionData.predictionRate,
                          actualSeizureOccurred: true, // 발작 발생
                        );

                        // 기존 콜백 호출 (발작 기록 저장용)
                        if (onSeizureConfirmed != null) {
                          onSeizureConfirmed!();
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('발작 정보가 기록되었습니다. 개인 맞춤 예측에 활용됩니다.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResponseButton(
                      context,
                      label: '아니요',
                      onPressed: () async {
                        // 발작 미발생 확인 - 학습 피드백 전송
                        await BackendService.submitPredictionFeedback(
                          timestamp: DateTime.now(),
                          predictionRate: predictionData.predictionRate,
                          actualSeizureOccurred: false, // 발작 미발생
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('응답이 기록되었습니다. 개인 맞춤 예측에 활용됩니다.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // 발작 대처방안 가이드
              _buildEmergencyGuide(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 발작 대처방안 가이드
  Widget _buildEmergencyGuide(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '발작 대처방안',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 만화 placeholder (4-panel grid)
                const Text(
                  '발작 대처 순서',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Emergency.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // 상세 텍스트
                const Text(
                  '소아 발작 응급처치 방법',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildGuideStep(
                  '1',
                  '주변을 안전하게 만드세요',
                  '아이 주변의 위험한 물건(가구, 날카로운 물건 등)을 치우세요. '
                      '아이가 다치지 않도록 부드러운 곳으로 옮기거나 주변을 정리합니다.',
                ),

                _buildGuideStep(
                  '2',
                  '옆으로 눕히세요',
                  '아이를 옆으로 눕혀주세요. 이는 침이나 구토물이 기도를 막지 않도록 '
                      '하는 회복 자세입니다. 머리 아래 부드러운 것을 받쳐주세요.',
                ),

                _buildGuideStep(
                  '3',
                  '억지로 움직이거나 잡지 마세요',
                  '발작 중에는 아이를 억지로 잡거나 움직임을 제한하지 마세요. '
                      '자연스럽게 발작이 끝날 때까지 기다립니다.',
                ),

                _buildGuideStep(
                  '4',
                  '입에 아무것도 넣지 마세요',
                  '혀를 깨물까봐 손가락이나 물건을 입에 넣는 것은 매우 위험합니다. '
                      '오히려 질식이나 부상의 위험이 있습니다.',
                ),

                _buildGuideStep(
                  '5',
                  '발작 시간을 체크하세요',
                  '발작이 시작된 시간을 확인하세요. 5분 이상 발작이 지속되거나, '
                      '발작이 연속적으로 일어나면 즉시 119에 신고하세요.',
                ),

                const SizedBox(height: 16),

                // 119 신고 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '119 신고가 필요한 경우',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• 발작이 5분 이상 지속될 때\n'
                              '• 발작 후 의식이 돌아오지 않을 때\n'
                              '• 연속으로 발작이 일어날 때\n'
                              '• 호흡곤란이 있을 때',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF5B7FFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 발작 예측 확률 카드
  Widget _buildPredictionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '발작예측확률',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${predictionData.predictionRate.toInt()}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 데이터 테이블
  Widget _buildDataTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    '데이터',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '수치',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '평상시 대비 수치',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 데이터 행들
          _buildDataRow('EMG (근전도)', predictionData.emg),
          _buildDataRow('ECG (심전도)', predictionData.ecg),
          _buildDataRow('가속도계', predictionData.accelerometer),
          _buildDataRow('수면 시간', predictionData.sleepTime),
          _buildDataRow('케톤 식이 순응도', predictionData.ketoAdherence),
          _buildDataRow('복약 준수율', predictionData.medicationAdherence),
          _buildDataRow('스트레스 지수', predictionData.stressIndex),
        ],
      ),
    );
  }

  /// 데이터 행
  Widget _buildDataRow(String label, MedicalDataItem dataItem) {
    final bool isIncreased = dataItem.isIncrease ?? false;

    // 변화율에 따른 색상 결정
    Color changeColor = Colors.black87;
    if (dataItem.changeRate != null && dataItem.isIncrease != null) {
      changeColor = isIncreased ? Colors.red : Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          // 데이터 이름
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // 수치
          Expanded(
            flex: 2,
            child: Text(
              dataItem.displayValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 평상시 대비 수치
          Expanded(
            flex: 2,
            child: Text(
              dataItem.displayChange,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: changeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 예/아니요 버튼
  Widget _buildResponseButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9E9E9E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// 도움 요청
  void _requestHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('도움 요청'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '긴급 연락처를 선택하세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 119 (응급전화)
            _buildEmergencyContactCard(
              context,
              icon: Icons.local_hospital,
              label: '119 (응급전화)',
              phoneNumber: '119',
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            // 보호자 연락처
            _buildEmergencyContactCard(
              context,
              icon: Icons.person,
              label: '보호자',
              phoneNumber: '010-1234-5678', // TODO: 실제 보호자 번호 연동
              color: const Color(0xFF5B7FFF),
            ),

            const SizedBox(height: 12),

            // 주치의 연락처
            _buildEmergencyContactCard(
              context,
              icon: Icons.medical_services,
              label: '주치의',
              phoneNumber: '02-1234-5678', // TODO: 실제 주치의 번호 연동
              color: const Color(0xFF43A047),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 긴급 연락처 카드
  Widget _buildEmergencyContactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String phoneNumber,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _makePhoneCall(context, phoneNumber, label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('전화하기', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendAlert(context, phoneNumber, label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.notifications, size: 16),
                    label: const Text('알림 보내기', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 전화 걸기
  Future<void> _makePhoneCall(
    BuildContext context,
    String phoneNumber,
    String label,
  ) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        debugPrint('전화 걸기: $label ($phoneNumber)');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('전화를 걸 수 없습니다: $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('전화 걸기 오류: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('전화를 거는 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 알림 보내기
  Future<void> _sendAlert(
    BuildContext context,
    String phoneNumber,
    String label,
  ) async {
    Navigator.pop(context); // 다이얼로그 닫기

    // TODO: 백엔드로 긴급 도움 요청 전송
    // - 현재 위치
    // - 발작 예측 확률
    // - 타임스탬프
    // - 연락처로 푸시 알림/SMS 발송
    debugPrint('=== 긴급 알림 전송 ===');
    debugPrint('수신자: $label ($phoneNumber)');
    debugPrint('예측 확률: ${predictionData.predictionRate}%');
    debugPrint('시간: ${DateTime.now()}');
    debugPrint('===================');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label에게 긴급 알림을 보냈습니다'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
