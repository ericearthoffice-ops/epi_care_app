import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import '../models/medication.dart';
import '../models/medication_schedule.dart' as schedule;
import 'medication_setup_screen.dart';

/// 복용 약 확인 및 관리 화면 (이미 설정한 사람용)
class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  // TODO: 백엔드에서 저장된 스케줄 불러오기
  late List<schedule.MedicationSchedule> _schedules;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  /// 저장된 스케줄 불러오기
  void _loadSchedules() {
    // TODO: 실제 백엔드에서 데이터 로드
    // Mock 데이터로 시연
    _schedules = [
      schedule.MedicationSchedule(
        medication: Medication(
          englishName: 'Levetiracetam',
          koreanName: '레비티라세탐',
        ),
        dailyFrequency: 2,
        times: [
          schedule.TimeOfDay(hour: 9, minute: 0),
          schedule.TimeOfDay(hour: 21, minute: 0),
        ],
        dosage: '1정',
        notes: '식후 30분',
      ),
      schedule.MedicationSchedule(
        medication: Medication(
          englishName: 'Valproate',
          koreanName: '발프로산',
        ),
        dailyFrequency: 3,
        times: [
          schedule.TimeOfDay(hour: 8, minute: 0),
          schedule.TimeOfDay(hour: 14, minute: 0),
          schedule.TimeOfDay(hour: 20, minute: 0),
        ],
        dosage: '2정',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '복용 약 관리',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // 약 추가 버튼
          if (!_isDeleteMode)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5B7FFF)),
              onPressed: _addMedication,
              tooltip: '약 추가',
            ),
          // 삭제 모드 토글
          IconButton(
            icon: Icon(
              _isDeleteMode ? Icons.check : Icons.delete_outline,
              color: _isDeleteMode ? Colors.red : Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isDeleteMode = !_isDeleteMode;
              });
            },
            tooltip: _isDeleteMode ? '완료' : '약 삭제',
          ),
        ],
      ),
      body: _schedules.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              return _buildMedicationCard(_schedules[index], index);
            },
          ),
    );
  }

  /// 약품 카드
  Widget _buildMedicationCard(schedule.MedicationSchedule medicationSchedule, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // 헤더 (약품명 + 삭제 버튼)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5B7FFF).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicationSchedule.medication.englishName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medicationSchedule.medication.koreanName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isDeleteMode)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _deleteMedication(index),
                  ),
              ],
            ),
          ),

          // 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 복용 횟수
                _buildInfoRow(
                  '복용 횟수',
                  '하루 ${medicationSchedule.dailyFrequency}회',
                  icon: Icons.repeat,
                  onEdit: () => _editFrequency(index),
                ),

                const SizedBox(height: 12),

                // 복용 시간
                _buildTimesSection(medicationSchedule, index),

                const SizedBox(height: 12),

                // 복용 용량
                _buildInfoRow(
                  '복용 용량',
                  medicationSchedule.dosage,
                  icon: Icons.medication,
                  onEdit: () => _editDosage(index),
                ),

                if (medicationSchedule.notes != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '메모',
                    medicationSchedule.notes!,
                    icon: Icons.note,
                    onEdit: () => _editNotes(index),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(String label, String value, {required IconData icon, VoidCallback? onEdit}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (!_isDeleteMode && onEdit != null)
          IconButton(
            icon: Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
            onPressed: onEdit,
          ),
      ],
    );
  }

  /// 복용 시간 섹션
  Widget _buildTimesSection(schedule.MedicationSchedule medicationSchedule, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              '복용 시간',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: medicationSchedule.times.asMap().entries.map((entry) {
            final timeIndex = entry.key;
            final time = entry.value;
            return InkWell(
              onTap: _isDeleteMode ? null : () => _editTime(index, timeIndex),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5B7FFF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${timeIndex + 1}회',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B7FFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time.formatAmPm(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B7FFF),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 비어있는 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '기록된 약이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 약 추가
  Future<void> _addMedication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicationSetupScreen(),
      ),
    );

    if (result == true) {
      // TODO: 백엔드에서 새로 추가된 스케줄 다시 로드
      setState(() {
        _loadSchedules();
      });
    }
  }

  /// 약 삭제
  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약 삭제'),
        content: Text(
          '${_schedules[index].medication.displayName}을(를) 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _schedules.removeAt(index);
                if (_schedules.isEmpty) {
                  _isDeleteMode = false;
                }
              });
              // TODO: 백엔드에 삭제 요청
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('약이 삭제되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 복용 횟수 수정
  void _editFrequency(int index) {
    showDialog(
      context: context,
      builder: (context) {
        int newFrequency = _schedules[index].dailyFrequency;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('복용 횟수 수정'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: newFrequency > 1
                      ? () => setDialogState(() => newFrequency--)
                      : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '하루 $newFrequency회',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: newFrequency < 6
                      ? () => setDialogState(() => newFrequency++)
                      : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _schedules[index].dailyFrequency = newFrequency;
                      _schedules[index].updateTimesForFrequency();
                    });
                    // TODO: 백엔드에 업데이트 요청
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7FFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 복용 시간 수정
  Future<void> _editTime(int scheduleIndex, int timeIndex) async {
    final currentTime = _schedules[scheduleIndex].times[timeIndex];

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
        _schedules[scheduleIndex].times[timeIndex] = schedule.TimeOfDay(
          hour: picked.hour,
          minute: picked.minute,
        );
      });
      // TODO: 백엔드에 업데이트 요청
    }
  }

  /// 복용 용량 수정
  void _editDosage(int index) {
    final controller = TextEditingController(text: _schedules[index].dosage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('복용 용량 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '예: 1정, 5ml, 1포',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _schedules[index].dosage = controller.text;
                });
                // TODO: 백엔드에 업데이트 요청
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B7FFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 메모 수정
  void _editNotes(int index) {
    final controller = TextEditingController(text: _schedules[index].notes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '식전/식후, 주의사항 등',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _schedules[index].notes = controller.text.isEmpty ? null : controller.text;
              });
              // TODO: 백엔드에 업데이트 요청
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B7FFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
