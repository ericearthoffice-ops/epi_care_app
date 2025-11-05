import 'package:flutter/material.dart';
import '../models/seizure_record.dart';

/// 발작 세부정보 화면
/// - 읽기 모드: 정보 표시만
/// - 편집 모드: 수정 가능
class SeizureDetailScreen extends StatefulWidget {
  final SeizureRecord record;

  const SeizureDetailScreen({
    super.key,
    required this.record,
  });

  @override
  State<SeizureDetailScreen> createState() => _SeizureDetailScreenState();
}

class _SeizureDetailScreenState extends State<SeizureDetailScreen> {
  // 편집 모드 여부
  bool _isEditMode = false;

  // 편집용 컨트롤러
  late DateTime _selectedDate;
  late TextEditingController _minutesController;
  late String _selectedSeizureType;
  late TextEditingController _notesController;
  late TextEditingController _symptomsController;

  // 발작 종류 목록
  final List<String> _seizureTypes = [
    '소발작',
    '대발작',
    '결신 발작',
    '근간대성 발작',
    '간대성 발작',
    '강직성 발작',
    '무긴장성 발작',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// 컨트롤러 초기화 (기존 데이터로)
  void _initializeControllers() {
    _selectedDate = widget.record.date;
    _minutesController = TextEditingController(
      text: widget.record.duration.inMinutes.toString(),
    );
    _selectedSeizureType = '소발작'; // TODO: record에서 가져오기
    _notesController = TextEditingController(
      text: widget.record.note ?? '',
    );
    _symptomsController = TextEditingController(
      text: '', // TODO: record에 증상 필드 추가 시
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _notesController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  /// 편집 모드 전환
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // 편집 취소 시 원래 데이터로 복원
        _initializeControllers();
      }
    });
  }

  /// 수정 사항 저장
  void _saveChanges() {
    // 입력 검증
    if (_minutesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지속 시간을 입력해주세요')),
      );
      return;
    }

    final int minutes = int.tryParse(_minutesController.text) ?? 0;

    debugPrint('=== 발작 기록 수정 ===');
    debugPrint('ID: ${widget.record.id}');
    debugPrint('날짜: $_selectedDate');
    debugPrint('지속시간: $minutes분');
    debugPrint('발작 종류: $_selectedSeizureType');
    debugPrint('특이사항: ${_notesController.text}');
    debugPrint('증상: ${_symptomsController.text}');
    debugPrint('===================');

    // TODO: BackendService.updateSeizureRecord() 호출

    setState(() {
      _isEditMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('발작 기록이 수정되었습니다')),
    );
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
        title: Text(
          _isEditMode ? '발작 기록 수정' : '발작 세부정보',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isEditMode ? _saveChanges : _toggleEditMode,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                _isEditMode ? '저장' : '수정',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isEditMode ? _buildEditMode() : _buildReadMode(),
      ),
    );
  }

  /// 읽기 모드 UI
  Widget _buildReadMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 및 시간
              const Text(
                '날짜',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.record.date.year}년 ${widget.record.date.month}월 ${widget.record.date.day}일',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.record.timeDisplay,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const Divider(height: 32),

              // 지속시간
              _buildReadOnlyField('발작 지속 시간', widget.record.durationDisplay),

              const SizedBox(height: 16),

              // 발작 종류
              _buildReadOnlyField('발작 종류', _selectedSeizureType),

              const SizedBox(height: 16),

              // 특이사항
              if (widget.record.note != null) ...[
                _buildReadOnlyField('특이사항', widget.record.note!),
                const SizedBox(height: 16),
              ],

              // 증상
              _buildReadOnlyField('증상', _symptomsController.text.isEmpty ? '기록 없음' : _symptomsController.text),
            ],
          ),
        ),
      ],
    );
  }

  /// 읽기 전용 필드
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 편집 모드 UI (발작 기록 입력 화면과 동일)
  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 섹션
        _buildSectionTitle('날짜'),
        const SizedBox(height: 8),
        _buildDateSelector(),

        const SizedBox(height: 24),

        // 발작 지속 시간
        _buildSectionTitle('발작 지속 시간'),
        const SizedBox(height: 8),
        _buildDurationInput(),

        const SizedBox(height: 24),

        // 발작 종류
        _buildSectionTitle('발작 종류'),
        const SizedBox(height: 8),
        _buildSeizureTypeDropdown(),

        const SizedBox(height: 24),

        // 특이사항
        _buildSectionTitle('특이사항'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _notesController,
          hintText: '무엇을 하다가 일어났는지, 시간은 얼마나 걸렸는지 등',
          maxLines: 4,
        ),

        const SizedBox(height: 24),

        // 증상
        _buildSectionTitle('증상'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _symptomsController,
          hintText: '발작 중이나 발작 후 증상 상세 기록',
          maxLines: 4,
        ),
      ],
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

  /// 날짜 선택기
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDateButton('${_selectedDate.year}', '년'),
          const SizedBox(width: 16),
          _buildDateButton('${_selectedDate.month}', '월'),
          const SizedBox(width: 16),
          _buildDateButton('${_selectedDate.day}', '일'),
        ],
      ),
    );
  }

  /// 날짜 버튼
  Widget _buildDateButton(String value, String unit) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 지속 시간 입력
  Widget _buildDurationInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '분',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 발작 종류 드롭다운
  Widget _buildSeizureTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: _selectedSeizureType,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedSeizureType = newValue;
            });
          }
        },
        items: _seizureTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 텍스트 입력 필드
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5B7FFF), width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
