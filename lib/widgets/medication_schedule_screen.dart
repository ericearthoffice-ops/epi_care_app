import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import '../models/medication.dart';
import '../models/medication_schedule.dart' as schedule;
import '../services/medication_notification_service.dart';

/// 복용 스케줄 설정 화면
class MedicationScheduleScreen extends StatefulWidget {
  final List<Medication> selectedMedications;

  const MedicationScheduleScreen({
    super.key,
    required this.selectedMedications,
  });

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late List<schedule.MedicationSchedule> _schedules;
  late List<TextEditingController> _dosageControllers;
  late List<TextEditingController> _notesControllers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _schedules = widget.selectedMedications.map((med) {
      return schedule.MedicationSchedule(medication: med);
    }).toList();

    _dosageControllers = List.generate(
      _schedules.length,
      (index) => TextEditingController(),
    );

    _notesControllers = List.generate(
      _schedules.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _dosageControllers) {
      controller.dispose();
    }
    for (var controller in _notesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  schedule.MedicationSchedule get _currentSchedule => _schedules[_currentIndex];

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
      ),
      body: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '복용 정보 입력',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentIndex + 1}/${_schedules.length} - ${_currentSchedule.medication.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // 진행 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _schedules.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
                minHeight: 6,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 입력 폼
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 하루 복용 횟수
                  _buildSectionTitle('하루 복용 횟수'),
                  const SizedBox(height: 12),
                  _buildFrequencySelector(),

                  const SizedBox(height: 32),

                  // 복용 시간
                  _buildSectionTitle('복용 시간'),
                  const SizedBox(height: 12),
                  _buildTimeSelectors(),

                  const SizedBox(height: 32),

                  // 복용 용량
                  _buildSectionTitle('복용 용량'),
                  const SizedBox(height: 12),
                  _buildDosageInput(),

                  const SizedBox(height: 32),

                  // 메모 (선택사항)
                  _buildSectionTitle('메모 (선택사항)'),
                  const SizedBox(height: 12),
                  _buildNotesInput(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5B7FFF),
                        side: const BorderSide(color: Color(0xFF5B7FFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '이전',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isCurrentScheduleValid() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B7FFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _currentIndex < _schedules.length - 1 ? '다음' : '완료',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// 복용 횟수 선택
  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '하루',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentSchedule.dailyFrequency > 1
                  ? () {
                      setState(() {
                        _currentSchedule.dailyFrequency--;
                        _currentSchedule.updateTimesForFrequency();
                      });
                    }
                  : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _currentSchedule.dailyFrequency > 1
                    ? const Color(0xFF5B7FFF)
                    : Colors.grey.shade300,
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '${_currentSchedule.dailyFrequency}회',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentSchedule.dailyFrequency < 6
                  ? () {
                      setState(() {
                        _currentSchedule.dailyFrequency++;
                        _currentSchedule.updateTimesForFrequency();
                      });
                    }
                  : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _currentSchedule.dailyFrequency < 6
                    ? const Color(0xFF5B7FFF)
                    : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 복용 시간 선택기들
  Widget _buildTimeSelectors() {
    return Column(
      children: List.generate(_currentSchedule.dailyFrequency, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTimeSelector(index),
        );
      }),
    );
  }

  /// 개별 시간 선택기 (안드로이드 알람 스타일)
  Widget _buildTimeSelector(int index) {
    final time = _currentSchedule.times[index];

    return InkWell(
      onTap: () => _selectTime(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B7FFF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}번째 복용',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time.formatAmPm(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 시간 선택 다이얼로그
  Future<void> _selectTime(int index) async {
    final currentTime = _currentSchedule.times[index];

    final material.TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: material.TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
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
        _currentSchedule.times[index] = schedule.TimeOfDay(
          hour: picked.hour,
          minute: picked.minute,
        );
      });
    }
  }

  /// 복용 용량 입력
  Widget _buildDosageInput() {
    return TextField(
      controller: _dosageControllers[_currentIndex],
      onChanged: (value) {
        setState(() {
          _currentSchedule.dosage = value;
        });
      },
      decoration: InputDecoration(
        hintText: '예: 1정, 5ml, 1포',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B7FFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  /// 메모 입력
  Widget _buildNotesInput() {
    return TextField(
      controller: _notesControllers[_currentIndex],
      onChanged: (value) {
        _currentSchedule.notes = value.isEmpty ? null : value;
      },
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '식전/식후, 주의사항 등을 입력하세요',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B7FFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  /// 현재 스케줄이 유효한지 확인
  bool _isCurrentScheduleValid() {
    return _dosageControllers[_currentIndex].text.isNotEmpty;
  }

  /// 다음/완료 처리
  void _handleNext() {
    if (_currentIndex < _schedules.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // 모든 스케줄 입력 완료
      _saveMedicationSchedules();
    }
  }

  /// 복용 스케줄 저장 및 백엔드 전송
  Future<void> _saveMedicationSchedules() async {
    // TODO: 실제 백엔드로 데이터 전송
    debugPrint('=== 복용 스케줄 설정 완료 ===');
    for (var schedule in _schedules) {
      debugPrint('약품: ${schedule.medication.displayName}');
      debugPrint('  - 하루 ${schedule.dailyFrequency}회');
      debugPrint('  - 시간: ${schedule.times.map((t) => t.format24Hour()).join(", ")}');
      debugPrint('  - 용량: ${schedule.dosage}');
      if (schedule.notes != null) {
        debugPrint('  - 메모: ${schedule.notes}');
      }
    }

    // 백엔드 전송 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 복용 알림 예약
    try {
      await MedicationNotificationService().scheduleMedicationAlarms(_schedules);
      debugPrint('복용 알림 예약 완료');
    } catch (e) {
      debugPrint('알림 예약 실패: $e');
    }

    if (!mounted) return;

    // 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복용 알림이 설정되었습니다!'),
        backgroundColor: Color(0xFF5B7FFF),
      ),
    );

    // 식이/복용 화면으로 돌아가면서 설정 완료 상태 전달
    Navigator.pop(context, true); // true = 설정 완료
    Navigator.pop(context, true);
  }
}
