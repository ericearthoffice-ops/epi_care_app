import 'package:flutter/material.dart';
import '../models/medical_report.dart';
import 'medical_report_preview_screen.dart';

/// 의료 보고서 기간 선택 화면
class MedicalReportPeriodScreen extends StatefulWidget {
  const MedicalReportPeriodScreen({super.key});

  @override
  State<MedicalReportPeriodScreen> createState() =>
      _MedicalReportPeriodScreenState();
}

class _MedicalReportPeriodScreenState
    extends State<MedicalReportPeriodScreen> {
  ReportPeriodType _selectedPeriod = ReportPeriodType.oneMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

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
          '의료 보고서 생성',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 텍스트
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
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF5B7FFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '의료진에게 제출할 건강 기록을 PDF로 생성합니다.\n기간을 선택해주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '기간 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // 기간 옵션들
            ...ReportPeriodType.values.map((period) {
              return _buildPeriodOption(period);
            }),

            // 사용자 지정 날짜 선택
            if (_selectedPeriod == ReportPeriodType.custom) ...[
              const SizedBox(height: 20),
              _buildCustomDateSelector(),
            ],

            const SizedBox(height: 32),

            // 보고서 생성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canGenerateReport ? _generateReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '보고서 생성하기',
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

  /// 기간 옵션 위젯
  Widget _buildPeriodOption(ReportPeriodType period) {
    final isSelected = _selectedPeriod == period;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            if (period != ReportPeriodType.custom) {
              _customStartDate = null;
              _customEndDate = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5B7FFF).withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF5B7FFF)
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5B7FFF)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected
                      ? const Color(0xFF5B7FFF)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  period.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.black54,
                  ),
                ),
              ),
              if (period != ReportPeriodType.custom)
                Text(
                  '${period.days}일',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자 지정 날짜 선택기
  Widget _buildCustomDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기간 설정',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: '시작일',
                  date: _customStartDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _customStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _customStartDate = picked;
                      });
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 20),
              ),
              Expanded(
                child: _buildDateButton(
                  label: '종료일',
                  date: _customEndDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _customEndDate ?? DateTime.now(),
                      firstDate: _customStartDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _customEndDate = picked;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 날짜 선택 버튼
  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
                  : '날짜 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: date != null ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 보고서 생성 가능 여부
  bool get _canGenerateReport {
    if (_selectedPeriod == ReportPeriodType.custom) {
      return _customStartDate != null && _customEndDate != null;
    }
    return true;
  }

  /// 보고서 생성
  void _generateReport() {
    DateTime startDate;
    DateTime endDate = DateTime.now();

    if (_selectedPeriod == ReportPeriodType.custom) {
      startDate = _customStartDate!;
      endDate = _customEndDate!;
    } else {
      startDate = DateTime.now().subtract(Duration(days: _selectedPeriod.days));
    }

    // PDF 미리보기 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalReportPreviewScreen(
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }
}
