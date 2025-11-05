import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import '../models/medication_log.dart';
import '../services/medication_notification_service.dart';

/// 복용 시간 입력 화면 (3회 무응답 후 입력용)
class MedicationTimeInputScreen extends StatefulWidget {
  final int notificationId;
  final String medicationName;

  const MedicationTimeInputScreen({
    super.key,
    required this.notificationId,
    required this.medicationName,
  });

  @override
  State<MedicationTimeInputScreen> createState() => _MedicationTimeInputScreenState();
}

class _MedicationTimeInputScreenState extends State<MedicationTimeInputScreen> {
  DateTime? _selectedDate;
  material.TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '복용 시간 입력',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF5B7FFF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF5B7FFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '마지막 복용 시간을 입력해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 약품명
            const Text(
              '약품',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.medicationName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 날짜 선택
            const Text(
              '복용 날짜',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? const Color(0xFF5B7FFF)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _selectedDate != null
                          ? const Color(0xFF5B7FFF)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                            : '날짜를 선택하세요',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 시간 선택
            const Text(
              '복용 시간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTime != null
                        ? const Color(0xFF5B7FFF)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _selectedTime != null
                          ? const Color(0xFF5B7FFF)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTime != null
                            ? _formatTime(_selectedTime!)
                            : '시간을 선택하세요',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedTime != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isValid() ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B7FFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 시간 선택
  Future<void> _selectTime() async {
    final material.TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? material.TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B7FFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 시간 포맷팅
  String _formatTime(material.TimeOfDay time) {
    final period = time.hour < 12 ? '오전' : '오후';
    final displayHour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    return '$period ${displayHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 유효성 검사
  bool _isValid() {
    return _selectedDate != null && _selectedTime != null;
  }

  /// 저장
  Future<void> _save() async {
    if (!_isValid()) return;

    final actualTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // 복용 기록 생성
    final log = MedicationLog(
      medicationName: widget.medicationName,
      scheduledTime: DateTime.now(), // 원래 예정 시간은 서비스에서 가져와야 하지만 여기서는 간소화
      actualTime: actualTime,
      status: MedicationStatus.taken,
      notificationAttempts: 3, // 3회 시도 후 입력
    );

    // 백엔드로 전송
    debugPrint('=== 복용 시간 입력 완료 ===');
    debugPrint('약품: ${widget.medicationName}');
    debugPrint('복용 시간: $actualTime');
    debugPrint('로그 데이터: ${log.toJson()}');
    // TODO: 백엔드 API 호출 - log 데이터 전송

    // 알림 취소
    await MedicationNotificationService().cancelNotification(widget.notificationId);

    if (!mounted) return;

    // 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복용 시간이 기록되었습니다'),
        backgroundColor: Color(0xFF5B7FFF),
      ),
    );

    // 화면 닫기
    Navigator.pop(context);
  }
}
