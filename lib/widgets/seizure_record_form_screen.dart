import 'package:flutter/material.dart';

/// 발작 기록 추가 화면
class SeizureRecordFormScreen extends StatefulWidget {
  const SeizureRecordFormScreen({super.key});

  @override
  State<SeizureRecordFormScreen> createState() => _SeizureRecordFormScreenState();
}

class _SeizureRecordFormScreenState extends State<SeizureRecordFormScreen> {
  // 날짜 선택
  DateTime _selectedDate = DateTime.now();

  // 지속 시간 (분)
  final TextEditingController _minutesController = TextEditingController();

  // 발작 종류
  String _selectedSeizureType = '소발작';
  final List<String> _seizureTypes = [
    '소발작',
    '대발작',
    '결신 발작',
    '근간대성 발작',
    '간대성 발작',
    '강직성 발작',
    '무긴장성 발작',
  ];

  // 특이사항, 증상
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    _notesController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      // locale 파라미터 제거 (시스템 언어 사용)
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 저장 버튼 클릭
  void _saveRecord() {
    // TODO: 백엔드로 데이터 전송
    // 입력 데이터 검증
    if (_minutesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지속 시간을 입력해주세요')),
      );
      return;
    }

    // 데이터 수집
    final int minutes = int.tryParse(_minutesController.text) ?? 0;

    debugPrint('=== 발작 기록 저장 ===');
    debugPrint('날짜: $_selectedDate');
    debugPrint('지속시간: $minutes분');
    debugPrint('발작 종류: $_selectedSeizureType');
    debugPrint('특이사항: ${_notesController.text}');
    debugPrint('증상: ${_symptomsController.text}');
    debugPrint('===================');

    // TODO: BackendService.saveSeizureRecord() 호출

    // 저장 후 뒤로가기
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('발작 기록이 저장되었습니다')),
    );
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
          tooltip: '발작 기록으로',
        ),
        title: const Text(
          '발작 기록하기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saveRecord,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                '저장',
                style: TextStyle(
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
        child: Column(
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
        ),
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
          // 분 입력
          SizedBox(
            width: 120,
            child: _buildTimeInput(
              controller: _minutesController,
              label: '분',
            ),
          ),
        ],
      ),
    );
  }

  /// 시간/분 입력 필드
  Widget _buildTimeInput({
    required TextEditingController controller,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
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
